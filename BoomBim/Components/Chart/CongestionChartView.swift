//
//  CongestionChartView.swift
//  BoomBim
//
//  Created by 조영현 on 10/28/25.
//

import SwiftUI
import Charts

final class ChartViewModel: ObservableObject {
    @Published var data: [HourPoint] = []
    
    var values: [Double] { data.map { $0.value }}
    var hours: [Int] { data.map { $0.hour } }
    var minHour: Int { hours.min() ?? 0 }
    var maxHour: Int { hours.max() ?? 23 }
    
    var currentHour: Int {
        Calendar.current.component(.hour, from: Date())
    }

    // hour가 정수 단위일 때, 사이값은 선형 보간
    func interpolatedValue(at hour: Int) -> Double? {
        let pts = data.sorted { $0.hour < $1.hour }
        if let exact = pts.first(where: { $0.hour == hour }) { return exact.value }
        guard
            let left = pts.last(where: { $0.hour < hour }),
            let right = pts.first(where: { $0.hour > hour })
        else { return nil }
        // hour는 정수라 t는 0~1 사이
        let t = Double(hour - left.hour) / Double(right.hour - left.hour)
        return (1 - t) * left.value + t * right.value
    }
}

struct CongestionChartView: View {
    @ObservedObject var viewModel: ChartViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            header
            VStack(alignment: .leading, spacing: 6) {
                legend
                chart
            }
        }
    }

    @ViewBuilder
    private var header: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text("시간별 혼잡도 예측")
                .font(Font(Typography.Body01.semiBold.font))
                .foregroundColor(.grayScale10)
                .frame(height: Typography.Body01.semiBold.lineHeight)
            Text("1시간 간격 예측")
                .font(Font(Typography.Body03.regular.font))
                .foregroundColor(.grayScale8)
                .frame(height: Typography.Body03.regular.lineHeight)
        }
    }

    @ViewBuilder
    private var legend: some View {
        HStack(spacing: 16) {
            legendDot(.relaxed,  color: .chartRelaxed)
            legendDot(.normal,   color: .chartNormal)
            legendDot(.busy, color: .chartBusy)
            legendDot(.crowded,  color: .chartCrowded)
        }
    }
    
    private let bandColors: [Color] = [
        Color(.chartRelaxed), // relaxed
        Color(.chartNormal), // normal
        Color(.chartBusy), // busy
        Color(.chartCrowded)  // crowded
    ]

    @ViewBuilder
    private var chart: some View {
        let bandWidth: CGFloat = 24      // 왼쪽 색 띠 너비
        let chartHeight: CGFloat = 150
        let innerPad: CGFloat = 6 // pt 단위, 원하는 만큼
        
        var axisHours: [Int] {
            Array(Set(viewModel.data.map { $0.hour })).sorted()
        }

        Chart {
            gridRules()
            lineAndPoints()
            currentTimeMark()
        }
        .chartXScale(
            domain: viewModel.minHour...viewModel.maxHour,
            range: .plotDimension(padding: innerPad)   // 좌우 여백 제거 → 색띠 끝에서 시작/끝
        )
        .chartYScale(
            domain: 0.0...100.0,
            range: .plotDimension(padding: 0)   // 위아래 여백 제거(선택)
        )

        // 1) 플롯 배경은 흰색, 2) 왼쪽에 내부 패딩을 줘서 색띠 공간 확보
        // 3) 그 패딩 공간(leading)에 색띠를 배경으로 깔기
        .chartPlotStyle { plot in
            plot
                .background(Color.white)
                .padding(.leading, bandWidth)
                .background(alignment: .leading) {
                    let w = bandWidth + 0.5
                    VStack(spacing: 0) {
                        // 레벨 수(4)만큼 균등한 높이의 색 블록
                        Color(.chartRelaxed)   // 여유
                        Color(.chartNormal)   // 보통
                        Color(.chartBusy)   // 약간 붐빔
                        Color(.chartCrowded)   // 붐빔
                    }
                    .frame(width: w)
                    .mask( // 플롯 높이에 정확히 4등분
                        VStack(spacing: 0) {
                            ForEach(0..<4) { _ in Rectangle() }
                        }
                    )
                }
        }

        // X축 눈금을 '실제 데이터 시간'으로 지정 → 포인트와 정확히 수직 정렬
        .chartXAxis(.hidden)     // 내장 X축 숨김
        .padding(.bottom, Typography.Caption.regular.lineHeight)
        .chartOverlay { proxy in
            GeometryReader { geo in
                let plotFrame = geo[proxy.plotAreaFrame]
                
                // hours는 표시할 정수 시간 배열
                ForEach( Array(stride(from: viewModel.minHour, through: viewModel.maxHour, by: 2)), id: \.self) { h in
                    if let x = proxy.position(forX: h) {
                        // 라벨을 플롯 하단에 정렬
                        Text("\(h)")
                            .font(Font(Typography.Caption.regular.font))
                            .foregroundStyle(Color(.grayScale7))
                            .position(x: x + plotFrame.minX,
                                      y: plotFrame.maxY + Typography.Caption.regular.lineHeight/2) // 하단 오프셋 -> 왜 나누기 2했는지
                    }
                }
            }
        }

        // Y축: 가로 그리드 라인만 보이게
        .chartYAxis {
            AxisMarks(values: [0,1,2,3,4]) { _ in
                AxisGridLine()
                AxisTick().foregroundStyle(.clear)
                AxisValueLabel().foregroundStyle(.clear)
            }
        }
        .frame(height: chartHeight)
    }


    @ChartContentBuilder
    private func bandsLayer() -> some ChartContent {
        ForEach(CongestionLevel.allCases, id: \.self) { level in
            RectangleMark(
                xStart: .value("시작", viewModel.minHour),
                xEnd:   .value("끝", viewModel.maxHour),
                yStart: .value("yStart", Double(level.bandIndex)),
                yEnd:   .value("yEnd", Double(level.bandIndex + 1))
            )
            .foregroundStyle(level.bandColor)
        }
    }
    
    @ChartContentBuilder
    private func gridRules() -> some ChartContent {
        // y 도메인이 0...100이므로 0,25,50,75,100에 5개 선
        ForEach([0, 25, 50, 75, 100], id: \.self) { y in
            RuleMark(y: .value("grid", y))
                .foregroundStyle(Color(.grayScale3))
                .lineStyle(StrokeStyle(lineWidth: 1))
                .zIndex(0) // 데이터(라인/포인트) 뒤
        }
    }

    @ChartContentBuilder
    private func lineAndPoints() -> some ChartContent {
        ForEach(viewModel.data) { item in
            LineMark(
                x: .value("hour", item.hour),
                y: .value("value", item.value)
            )
            .lineStyle(.init(lineWidth: 1))
            .foregroundStyle(Color(.main))

            PointMark(
                x: .value("hour", item.hour),
                y: .value("value", item.value)
            )
            .symbol(.circle)
            .symbolSize(28)
            .foregroundStyle(.white)                   // 채움 = 흰색
            .annotation(position: .overlay) {          // 테두리 = 메인컬러 1pt
                Circle()
                    .stroke(Color(UIColor.main), lineWidth: 1)
                    .frame(width: 6, height: 6)
                    .allowsHitTesting(false)
            }
        }
    }

    @ChartContentBuilder
    private func currentTimeMark() -> some ChartContent {
        if let y = viewModel.interpolatedValue(at: viewModel.currentHour) {
            RuleMark(x: .value("now", viewModel.currentHour),
                     yStart: .value("bottom", 0),
                     yEnd:   .value("y", y))
            .lineStyle(StrokeStyle(lineWidth: 1, dash: [4, 4]))
            .foregroundStyle(Color(.chartCurrentTimePoint))  // 원하는 컬러
            .zIndex(0.5) // 라인 뒤(0)와 데이터(1) 사이
            
            PointMark(
                x: .value("now-x", viewModel.currentHour),
                y: .value("now-y", y)
            )
            .symbol(.circle)
            .symbolSize(28)                    // 내부 흰 점 기준 면적
            .foregroundStyle(.clear)           // 흰 채움
            .annotation(position: .overlay) {
                ZStack {
                    // 바깥 노란 하이라이트 링(반투명)
                    Circle()
                        .fill(Color(.chartCurrentTimePoint).opacity(0.50))
                        .frame(width: 14, height: 14)
                    
                    // 내부 흰 원 + 노란 테두리(1pt)
                    Circle()
                        .fill(Color(.chartCurrentTimePoint))
                        .stroke(Color(UIColor.grayScale1), lineWidth: 1)
                        .frame(width: 6, height: 6)
                }
                .allowsHitTesting(false)
            }
            .zIndex(2) // 데이터보다 위
        }
    }
    
    private func legendDot(_ level: CongestionLevel, color: Color) -> some View {
        HStack(spacing: 8) {
            Circle().fill(color).frame(width: 8, height: 8)
            Text(level.description)
                .font(Font(Typography.Caption.regular.font))
                .foregroundColor(.grayScale9)
                .frame(height: Typography.Caption.regular.lineHeight)
        }
    }
}


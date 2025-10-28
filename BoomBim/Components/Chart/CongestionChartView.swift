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
    @Published var selectedHour: Int? = nil
    
    var values: [Double] { data.map { $0.value }}
    var hours: [Int] { data.map { $0.hour } }
    var minHour: Int { hours.min() ?? 0 }
    var maxHour: Int { hours.max() ?? 23 }
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
        let bandGap:   CGFloat = 8           // 띠와 데이터 사이 여백
        
        
        var axisHours: [Int] {
            Array(Set(viewModel.data.map { $0.hour })).sorted()
        }

        Chart {
            lineAndPoints()              // 기존 라인/포인트
//            selectionLayer()             // 선택 점선/말풍선(있다면)
        }
        .chartXScale(
            domain: viewModel.minHour...viewModel.maxHour,
            range: .plotDimension(padding: 0)   // 좌우 여백 제거 → 색띠 끝에서 시작/끝
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
                .padding(.leading, bandWidth + bandGap)
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
    private func selectionLayer() -> some ChartContent {
        if let h = viewModel.selectedHour,
           let sel = viewModel.data.first(where: { $0.hour == h }) {

            RuleMark(x: .value("선택 시", h))
                .lineStyle(.init(lineWidth: 1, dash: [4, 4]))
                .foregroundStyle(Color.orange)
                .annotation(position: .overlay, alignment: .topLeading) {
                    Circle()
                        .strokeBorder(Color.orange, lineWidth: 2)
                        .background(Circle().fill(Color.yellow.opacity(0.6)))
                        .frame(width: 18, height: 18)
                }
                .annotation(position: .top) {
                    Text("\(h)시")
                        .font(.caption2)
                        .padding(4)
                        .background(.ultraThinMaterial, in: Capsule())
                }

            PointMark(
                x: .value("시", sel.hour),
                y: .value("레벨", Double(sel.level.rawValue) + 0.5)
            )
            .annotation(position: .trailing) {
                selectionCallout(level: sel.level, value: Int(sel.value))
            }
        }
    }

    @ViewBuilder
    private func selectionCallout(level: CongestionLevel, value: Int) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(level.description).font(.caption).bold()
            Text("예측 \(value)").font(.caption2).foregroundStyle(.secondary)
        }
        .padding(8)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Color(.background))
                .shadow(radius: 1, y: 1)
        )
    }

    @AxisContentBuilder
    private func xAxis() -> some AxisContent {
        AxisMarks(values: .stride(by: 2)) { v in
            AxisGridLine().foregroundStyle(.clear)
            AxisTick()
            AxisValueLabel {
                if let hour: Int = v.as(Int.self) { Text("\(hour)") }
            }
        }
    }

    @AxisContentBuilder
    private func yAxis() -> some AxisContent {
        let ticks: [Double] = CongestionLevel.allCases.map { Double($0.rawValue) + 0.5 } // 타입 명시
        AxisMarks(values: ticks) { _ in
            AxisGridLine().foregroundStyle(.clear)
            AxisTick().foregroundStyle(.clear)
            AxisValueLabel().foregroundStyle(.clear)
        }
    }

    @ViewBuilder
    private func overlay(proxy: ChartProxy) -> some View {
        GeometryReader { geo in
            Rectangle().fill(.clear).contentShape(Rectangle())
                .gesture(
                    DragGesture(minimumDistance: 0)
                        .onChanged { value in
                            let origin = geo[proxy.plotAreaFrame].origin
                            let x = value.location.x - origin.x
                            if let hourVal: Int = proxy.value(atX: x) {
                                viewModel.selectedHour = nearestHour(to: hourVal)
                            }
                        }
                )
        }
    }
    
    private func nearestHour(to x: Int) -> Int {
        // 데이터에 존재하는 가장 가까운 시간으로 스냅
        guard let nearest = viewModel.hours.min(by: { abs($0 - x) < abs($1 - x) }) else { return x }
        return nearest
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


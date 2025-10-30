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

    var values: [Double] { data.map { $0.value } }
    var hours:  [Int]    { data.map { $0.hour  } }

    // 시작 시각(언랩 기준점) = 첫 데이터의 시간
    var startHour: Int { data.first?.hour ?? 0 }

    // 시(hour)를 단조증가로 언랩: 시작보다 작으면 +24
    func unwrap(_ h: Int) -> Int { h < startHour ? h + 24 : h }

    // 차트에 실제로 쓸 언랩 포인트
    struct UPoint: Identifiable {
        let id = UUID()
        let x: Int          // unwrapped hour (단조 증가)
        let hour24: Int     // 0~23 라벨 표기용
        let value: Double
        let level: CongestionLevel
    }

    // 변환된 포인트 배열 (data 순서를 보존)
    var unwrappedPoints: [UPoint] {
        data.map { .init(x: unwrap($0.hour), hour24: $0.hour, value: $0.value, level: $0.level) }
    }

    // X축 도메인
    var xMin: Int { unwrappedPoints.first?.x ?? 0 }
    var xMax: Int { unwrappedPoints.last?.x  ?? 23 }

    // X축 눈금 — 언랩 값으로 생성
    var axisHours: [Int] {
        Array(stride(from: xMin, through: xMax, by: 1))
    }

    // 현재 시(0~23)
    var currentHour: Int {
        startHour
//        Calendar.current.component(.hour, from: Date())
    }

    // 언랩된 시간축에서 선형 보간
    func interpolatedValueAtUnwrappedHour(_ ux: Int) -> Double? {
        let pts = unwrappedPoints
        if let exact = pts.first(where: { $0.x == ux }) { return exact.value }
        guard
            let left  = pts.last(where: { $0.x < ux }),
            let right = pts.first(where: { $0.x > ux })
        else { return nil }
        let t = Double(ux - left.x) / Double(right.x - left.x)
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
            lineAndPoints()        // 🔧 내부에서 unwrappedPoints 사용하도록 수정
            currentTimeMark()      // 🔧 언랩 기준으로 계산하도록 수정
        }
        .chartXScale(
            // 🔧 언랩된 도메인 사용
            domain: viewModel.xMin...viewModel.xMax,
            range: .plotDimension(padding: innerPad)
        )
        .chartYScale(
            domain: 0.0...100.0,
            range: .plotDimension(padding: 0)
        )
        .chartPlotStyle { plot in
            plot
                .background(Color.white)
                .padding(.leading, bandWidth)
                .background(alignment: .leading) {
                    let w: CGFloat = 24 + 0.5
                    VStack(spacing: 0) {
                        Color(.chartCrowded)
                        Color(.chartBusy)
                        Color(.chartNormal)
                        Color(.chartRelaxed)
                    }
                    .frame(width: w)
                    .mask(VStack(spacing: 0) { ForEach(0..<4) { _ in Rectangle() } })
                }
        }
        .chartXAxis(.hidden)
        .padding(.bottom, Typography.Caption.regular.lineHeight)
        .chartOverlay { proxy in
            GeometryReader { geo in
                let plot = geo[proxy.plotAreaFrame]
                // 🔧 언랩된 축 값에 맞춰 레이블, 표시는 %24
                ForEach(viewModel.axisHours, id: \.self) { ux in
                    if let x = proxy.position(forX: ux) {
                        Text("\(ux % 24)")
                            .font(Font(Typography.Caption.regular.font))
                            .foregroundStyle(Color(.grayScale7))
                            .position(x: x + plot.minX,
                                      y: plot.maxY + Typography.Caption.regular.lineHeight/2)
                    }
                }
            }
        }
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
        ForEach(viewModel.unwrappedPoints) { p in
            LineMark(
                x: .value("hour", p.x),
                y: .value("value", p.value)
            )
            .lineStyle(.init(lineWidth: 1))
            .foregroundStyle(Color(.main))
            .zIndex(1)

            PointMark(
                x: .value("hour", p.x),
                y: .value("value", p.value)
            )
            .symbol(.circle)
            .symbolSize(28)
            .foregroundStyle(.white)
            .annotation(position: .overlay) {
                Circle()
                    .stroke(Color(UIColor.main), lineWidth: 1)
                    .frame(width: 6, height: 6)
                    .allowsHitTesting(false)
            }
            .zIndex(2)
        }
    }

    @ChartContentBuilder
    private func currentTimeMark() -> some ChartContent {
        let ux = viewModel.unwrap(viewModel.currentHour)
        if ux >= viewModel.xMin, ux <= viewModel.xMax,
           let y = viewModel.interpolatedValueAtUnwrappedHour(ux) {

            RuleMark(x: .value("now", ux),
                     yStart: .value("bottom", 0),
                     yEnd:   .value("y", y))
            .lineStyle(StrokeStyle(lineWidth: 1, dash: [4, 4]))
            .foregroundStyle(Color(.chartCurrentTimePoint))
            .zIndex(0.5)

            PointMark(
                x: .value("now-x", ux),
                y: .value("now-y", y)
            )
            .symbol(.circle)
            .symbolSize(28)
            .foregroundStyle(.clear)
            .annotation(position: .overlay) {
                ZStack {
                    Circle()
                        .fill(Color(.chartCurrentTimePoint).opacity(0.50))
                        .frame(width: 14, height: 14)
                    Circle()
                        .fill(Color(.chartCurrentTimePoint))
                        .stroke(Color(UIColor.grayScale1), lineWidth: 1)
                        .frame(width: 6, height: 6)
                }
                .allowsHitTesting(false)
            }
            .zIndex(2)
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


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
    
    var hours: [Int] { data.map { $0.hour } }
    var minHour: Int { hours.min() ?? 6 }
    var maxHour: Int { hours.max() ?? 24 }
}

struct CongestionChartView: View {
    @ObservedObject var viewModel: ChartViewModel
//    let data: [HourPoint]                    // 시간별 데이터
//    @State private var selectedHour: Int?    // 탭/드래그로 선택
    
    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            header
            legend
            chart
        }
        .padding(16)
    }

    @ViewBuilder
    private var header: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("시간별 혼잡도 예측")
                .font(.system(size: 24, weight: .bold))
            Text("1시간 간격 예측")
                .foregroundColor(.secondary)
                .font(.system(size: 16, weight: .semibold))
        }
    }

    @ViewBuilder
    private var legend: some View {
        HStack(spacing: 16) {
            legendDot(.relaxed,  color: Color(hex: 0xD4EDC9))
            legendDot(.normal,   color: Color(hex: 0xCFE1FF))
            legendDot(.crowdedLite, color: Color(hex: 0xFFE49A))
            legendDot(.crowded,  color: Color(hex: 0xFFB0AC))
        }
    }

    @ViewBuilder
    private var chart: some View {
        Chart {
            bandsLayer()          // 배경 밴드
            lineAndPoints()       // 라인+포인트
            selectionLayer()      // 선택 점선/말풍선
        }
        .chartXAxis { xAxis() }
        .chartYAxis { yAxis() }
        .chartXScale(domain: viewModel.minHour...viewModel.maxHour)
        .chartYScale(domain: 0.0...4.0)            // Double로 명시
        .frame(height: 280)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.06), radius: 10, y: 4)
        )
        .chartOverlay { proxy in overlay(proxy: proxy) }
    }

    @ChartContentBuilder
    private func bandsLayer() -> some ChartContent {
        ForEach(CrowdLevel.allCases, id: \.self) { level in
            RectangleMark(
                xStart: .value("시작", viewModel.minHour),
                xEnd:   .value("끝", viewModel.maxHour),
                yStart: .value("yStart", Double(level.rawValue)),
                yEnd:   .value("yEnd", Double(level.rawValue + 1))
            )
            .foregroundStyle(level.bandColor)
        }
    }

    @ChartContentBuilder
    private func lineAndPoints() -> some ChartContent {
        ForEach(viewModel.data) { item in
            LineMark(
                x: .value("시", item.hour),
                y: .value("레벨", Double(item.level.rawValue) + 0.5)
            )
            .lineStyle(.init(lineWidth: 2))
            .foregroundStyle(Color.orange)

            PointMark(
                x: .value("시", item.hour),
                y: .value("레벨", Double(item.level.rawValue) + 0.5)
            )
            .symbolSize(30)
            .foregroundStyle(Color.orange)
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
    private func selectionCallout(level: CrowdLevel, value: Int) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(level.name).font(.caption).bold()
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
        let ticks: [Double] = CrowdLevel.allCases.map { Double($0.rawValue) + 0.5 } // 타입 명시
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
    
    private func legendDot(_ level: CrowdLevel, color: Color) -> some View {
        HStack(spacing: 6) {
            Circle().fill(color).frame(width: 12, height: 12)
            Text(level.name).font(.footnote)
        }
    }
}


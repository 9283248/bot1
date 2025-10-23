import Foundation
import SwiftUI

// MARK: - Base Protocol
protocol SlideElement: ObservableObject, Identifiable {
    var id: UUID { get }
    var position: CGPoint { get set }
    var size: CGSize { get set }
    var rotation: Double { get set }
    var opacity: Double { get set }
    var isSelected: Bool { get set }
}

// MARK: - Text Element
class TextElement: SlideElement {
    let id = UUID()
    @Published var position: CGPoint
    @Published var size: CGSize
    @Published var rotation: Double = 0
    @Published var opacity: Double = 1.0
    @Published var isSelected: Bool = false
    
    @Published var text: String
    @Published var fontSize: CGFloat
    @Published var fontWeight: Font.Weight
    @Published var textColor: Color
    @Published var textAlignment: TextAlignment
    @Published var backgroundColor: Color?
    @Published var cornerRadius: CGFloat
    
    init(
        text: String,
        fontSize: CGFloat = 16,
        position: CGPoint,
        size: CGSize,
        fontWeight: Font.Weight = .regular,
        textColor: Color = .black,
        textAlignment: TextAlignment = .leading,
        backgroundColor: Color? = nil,
        cornerRadius: CGFloat = 0
    ) {
        self.text = text
        self.position = position
        self.size = size
        self.fontSize = fontSize
        self.fontWeight = fontWeight
        self.textColor = textColor
        self.textAlignment = textAlignment
        self.backgroundColor = backgroundColor
        self.cornerRadius = cornerRadius
    }
}

// MARK: - Image Element
class ImageElement: SlideElement {
    let id = UUID()
    @Published var position: CGPoint
    @Published var size: CGSize
    @Published var rotation: Double = 0
    @Published var opacity: Double = 1.0
    @Published var isSelected: Bool = false
    
    @Published var image: UIImage
    @Published var contentMode: ContentMode
    @Published var cornerRadius: CGFloat
    
    init(
        image: UIImage,
        position: CGPoint,
        size: CGSize,
        contentMode: ContentMode = .fit,
        cornerRadius: CGFloat = 0
    ) {
        self.image = image
        self.position = position
        self.size = size
        self.contentMode = contentMode
        self.cornerRadius = cornerRadius
    }
}

// MARK: - Shape Element
class ShapeElement: SlideElement {
    let id = UUID()
    @Published var position: CGPoint
    @Published var size: CGSize
    @Published var rotation: Double = 0
    @Published var opacity: Double = 1.0
    @Published var isSelected: Bool = false
    
    @Published var shapeType: ShapeType
    @Published var fillColor: Color
    @Published var strokeColor: Color
    @Published var strokeWidth: CGFloat
    @Published var cornerRadius: CGFloat
    
    enum ShapeType: String, CaseIterable {
        case rectangle = "Прямоугольник"
        case circle = "Круг"
        case triangle = "Треугольник"
        case arrow = "Стрелка"
        case star = "Звезда"
    }
    
    init(
        shapeType: ShapeType,
        position: CGPoint,
        size: CGSize,
        fillColor: Color = .blue,
        strokeColor: Color = .clear,
        strokeWidth: CGFloat = 0,
        cornerRadius: CGFloat = 0
    ) {
        self.shapeType = shapeType
        self.position = position
        self.size = size
        self.fillColor = fillColor
        self.strokeColor = strokeColor
        self.strokeWidth = strokeWidth
        self.cornerRadius = cornerRadius
    }
}

// MARK: - Line Element
class LineElement: SlideElement {
    let id = UUID()
    @Published var position: CGPoint
    @Published var size: CGSize
    @Published var rotation: Double = 0
    @Published var opacity: Double = 1.0
    @Published var isSelected: Bool = false
    
    @Published var startPoint: CGPoint
    @Published var endPoint: CGPoint
    @Published var strokeColor: Color
    @Published var strokeWidth: CGFloat
    @Published var lineCap: CGLineCap
    
    init(
        startPoint: CGPoint,
        endPoint: CGPoint,
        strokeColor: Color = .black,
        strokeWidth: CGFloat = 2,
        lineCap: CGLineCap = .round
    ) {
        self.startPoint = startPoint
        self.endPoint = endPoint
        self.position = CGPoint(
            x: min(startPoint.x, endPoint.x),
            y: min(startPoint.y, endPoint.y)
        )
        self.size = CGSize(
            width: abs(endPoint.x - startPoint.x),
            height: abs(endPoint.y - startPoint.y)
        )
        self.strokeColor = strokeColor
        self.strokeWidth = strokeWidth
        self.lineCap = lineCap
    }
}

// MARK: - Chart Element
class ChartElement: SlideElement {
    let id = UUID()
    @Published var position: CGPoint
    @Published var size: CGSize
    @Published var rotation: Double = 0
    @Published var opacity: Double = 1.0
    @Published var isSelected: Bool = false
    
    @Published var chartType: ChartType
    @Published var data: [ChartDataPoint]
    @Published var title: String
    @Published var showLegend: Bool
    @Published var colors: [Color]
    
    enum ChartType: String, CaseIterable {
        case bar = "Столбчатая"
        case line = "Линейная"
        case pie = "Круговая"
    }
    
    struct ChartDataPoint: Identifiable {
        let id = UUID()
        let label: String
        let value: Double
    }
    
    init(
        chartType: ChartType,
        data: [ChartDataPoint],
        title: String = "",
        position: CGPoint,
        size: CGSize,
        showLegend: Bool = true,
        colors: [Color] = [.blue, .green, .orange, .red, .purple]
    ) {
        self.chartType = chartType
        self.data = data
        self.title = title
        self.position = position
        self.size = size
        self.showLegend = showLegend
        self.colors = colors
    }
}
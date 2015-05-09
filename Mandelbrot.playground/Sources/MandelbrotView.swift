import Cocoa

public class MandelbrotView: NSView
{
	public var mandelbrotRect = ComplexRect(Complex(-2.1, 1.5), Complex(1.0, -1.5))
	
	let rectScale = 1
	let blockiness = 0.5 // pick a value from 0.25 to 5.0
	let colorCount = 2000
	var colorSet : Array<NSColor> = Array()
	
	public override func drawRect(rect : CGRect)
	{
		
		NSBezierPath.fillRect(rect)
		let startTime = NSDate().timeIntervalSince1970
		drawMandelbrot(rect)
		let elapsedTime = NSDate().timeIntervalSince1970 - startTime
		println("Elapsed time: \(elapsedTime) seconds")
	}
	
	// Calculate whether the point is inside or outside the Mandelbrot set
	// Zn+1 = (Zn)^2 + c -- start with Z0 = 0
	func computeMandelbrotPoint(c: Complex) -> NSColor {
		var logConst = log(2.0)
		
		var z = Complex()
		
		for it in 1...colorCount {
			z = z * z + c
			var mod = modulus(z)
			if mod > 2 {
				var continuosIterations = CGFloat(Double(it) + 1.0 - log(log(sqrt(mod)) / logConst) / logConst)
				return NSColor(	red: CGFloat(sin(0.01 * continuosIterations + 1) * 0.5 + 0.5),
								green: CGFloat(sin(0.12 * continuosIterations + 2) * 0.5 + 0.5),
								blue: CGFloat(sin(0.13 * continuosIterations + 3) * 0.5 + 0.5),
								alpha: 1.0)
			}
		}
		// Yay, you're inside the set!
		return NSColor.blackColor()
	}
	
	func viewCoordinatesToComplexCoordinates(#x: Double, y: Double, rect: CGRect) -> Complex
	{
		let tl = mandelbrotRect.topLeft
		let br = mandelbrotRect.bottomRight
		let r = tl.real + (x/Double(rect.size.width * CGFloat(rectScale)))*(br.real - tl.real)
		let i = tl.imaginary + (y/Double(rect.size.height * CGFloat(rectScale)))*(br.imaginary - tl.imaginary)
		return Complex(r,i)
	}
	
	func complexCoordinatesToViewCoordinates(c: Complex, rect: CGRect) -> CGPoint
	{
		let tl = mandelbrotRect.topLeft
		let br = mandelbrotRect.bottomRight
		let x = (c.real - tl.real)/(br.real - tl.real)*Double(rect.size.width * CGFloat(rectScale))
		let y = (c.imaginary - tl.imaginary)/(br.imaginary - tl.imaginary)*Double(rect.size.height * CGFloat(rectScale))
		return CGPoint(x: x,y: y)
	}
	
	func drawMandelbrot(rect : CGRect)
	{
		var width:Double = Double(rect.size.width)
		var height:Double = Double(rect.size.height)
		let startTime = NSDate().timeIntervalSince1970
		
		for x in stride(from: 0, through: width, by: blockiness)
		{
			for y in stride(from: 0, through: height, by: blockiness)
			{
				let cc = viewCoordinatesToComplexCoordinates(x: x, y: y, rect: rect)
				computeMandelbrotPoint(cc).set()
				NSBezierPath.fillRect(CGRect(x: x, y: y, width: blockiness, height: blockiness))
			}
		}
		let elapsedTime = NSDate().timeIntervalSince1970 - startTime
		println("Calculation time: \(elapsedTime)")
	}
}
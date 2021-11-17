import Foundation
import WebRTC
import ReplayKit
import Promises

#if os(macOS)
class DesktopScreenCapturer: VideoCapturer, AVCaptureVideoDataOutputSampleBufferDelegate {

    let session: AVCaptureSession
    let input: AVCaptureScreenInput?
    let output: AVCaptureVideoDataOutput

    override init(delegate: RTCVideoCapturerDelegate) {
        session = AVCaptureSession()
        input = AVCaptureScreenInput(displayID: CGMainDisplayID())
        output = AVCaptureVideoDataOutput()
        output.videoSettings = [
            kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_420YpCbCr8BiPlanarFullRange
        ]
        super.init(delegate: delegate)
        output.setSampleBufferDelegate(self, queue: .main)

        // add I/O
        if let input = input {
            input.capturesCursor = true
            input.capturesMouseClicks = true
            session.addInput(input)
        }
        session.addOutput(output)
    }

    func startCapture() -> Promise<Void> {
        return Promise { () -> Void in
            self.session.startRunning()
        }
    }

    func stopCapture() -> Promise<Void> {
        return Promise { () -> Void in
            self.session.stopRunning()
        }
    }

    // MARK: - AVCaptureVideoDataOutputSampleBufferDelegate

    func captureOutput(_ output: AVCaptureOutput, didOutput
                        sampleBuffer: CMSampleBuffer,
                       from connection: AVCaptureConnection) {
        logger.debug("\(self) captured sample buffer")
        self.delegate?.capturer(self, didCapture: sampleBuffer)
    }
}
#endif
# ONAMCORDA GLASSES (ONA2)

Augmented Reality (AR) outline overlay glasses application targeting **iOS 18** on **iPhone 14 Pro**, designed to drive **Rokid Max** (or similar AR glasses) as an external display via **AirPlay**.

ONA2 captures live video from the iPhone camera, processes it to emphasize edges/contours, and renders an adjustable outline view to the AR glasses. The app has two main modes:

- **STOP mode** – configuration & preview (no live outline rendering to glasses)
- **START mode** – full-screen outline rendering with gesture-driven controls

---

## 1. Project Overview

ONA2 turns an iPhone into a real-time edge/outline generator for AR glasses:

- **Platform**: iOS 18+
- **Target device**: iPhone 14 Pro (primary development & tuning device)
- **Glasses**: Rokid Max (or other display glasses) used as an external display
- **Connection to glasses**: Rokid Max is typically connected as an **AirPlay external display**
- **Core idea**: Show a configurable high-contrast **outline view** to the user wearing the glasses, based on the live camera feed.

Workflow at a high level:

1. User connects **Rokid Max** as an external display using **AirPlay**.
2. User launches **ONA2** on the iPhone.
3. In **STOP mode**, user configures:
   - Which **camera** to use and how to orient the preview.
   - Which **glasses/external display** to target and how the image is positioned.
   - Visual properties such as **outline color** and whether the outline is visible.
4. User switches to **START mode**, where the outline view is:
   - Rendered full screen to the external display.
   - Controlled through touch gestures on the iPhone.

---

## 2. Main Components and Connections

### 2.1 Components

- **iPhone (host device)**
  - Runs the ONA2 app.
  - Captures camera frames.
  - Applies image-processing pipeline.
  - Streams the processed outline view to the external display.

- **Camera (input)**
  - Uses the iPhone’s built-in cameras (e.g., **back wide**, **back ultra-wide**, **front**).
  - Managed via **AVCaptureSession** and related APIs.

- **AR Glasses (Rokid Max)**
  - Act as an **external display**.
  - Typically connected wirelessly using **AirPlay**.
  - Show the processed outline view as a separate screen.

### 2.2 Connections

- **iPhone ↔ Camera**
  - **Internal hardware connection** managed by iOS.
  - ONA2 uses **AVCaptureDevice**, **AVCaptureSession**, and **AVCaptureVideoDataOutput** to receive frames.

- **iPhone ↔ AR Glasses**
  - **Primary**: **AirPlay** connection.
    - Rokid Max appears as an external display.
    - ONA2 renders a dedicated scene to this external screen.
  - **Other possible connections** (depending on hardware/OS):
    - **Cable** (USB-C / HDMI adapter) if available and supported.
    - **Wi‑Fi** (via AirPlay protocol).

- **Control channel (user gestures)**
  - User interacts with **the iPhone touchscreen**.
  - Gestures are recognized in a **UIKit touch surface** wrapped in SwiftUI.
  - The resulting parameters (zoom, pan, thresholds, etc.) are applied to the outline view sent to the glasses.

Summary of connection types used:

- **Bluetooth (BT)**: not used for the video path; may be used by system-level accessories but not central to ONA2.
- **Wi‑Fi**: used by **AirPlay** for streaming the external display.
- **Cable**: optional alternative to AirPlay if a wired connection is used.
- **AirPlay**: primary method for driving Rokid Max as an external display.

---

## 3. STOP Mode (Configuration & Preview)

**STOP mode** is the configuration state of ONA2. It is typically the **initial mode** when the app launches and is used to set up the camera, glasses, and basic visual parameters before starting the main outline rendering.

### 3.1 Purpose of STOP Mode

- Configure which **camera** to use.
- Configure how the video is **oriented and mirrored**.
- Configure which **external display** (glasses) is used and how the content fits.
- Configure **outline color** and visibility.
- Provide a **safe preview environment** without committing to the final viewing settings.

### 3.2 Camera Configuration

In STOP mode, the user can choose the active camera and control its orientation:

- **Camera selection**
  - Options commonly include:
    - Back wide camera
    - Back ultra-wide camera
    - Front camera
  - The selection affects both the preview on the iPhone and the image sent to the glasses in START mode.

- **Flip** (orientation swap)
  - Flips the camera preview horizontally (like a mirror) or vertically, depending on the configuration option.
  - Useful to match the perceived orientation inside the glasses.

- **Mirror**
  - Explicit mirror toggle for front-facing or back-facing camera.
  - Ensures that the direction of movement in reality aligns intuitively with what the user sees in the glasses.

### 3.3 Glasses / External Display Configuration

STOP mode includes configuration for how the image is displayed on the external screen:

- **Target display / glasses selection**
  - When an external display (e.g. Rokid Max) is detected via AirPlay or cable, it can be selected as the main output.

- **View size**
  - Controls how large the outline view is on the external screen.
  - Examples:
    - Full-screen fit
    - Letterboxed or pillarboxed to preserve aspect ratio
    - Custom scaling to adjust for comfort and optical quirks of the glasses.

- **Offsets (positioning)**
  - **Horizontal offset**: moves the image left/right.
  - **Vertical offset**: moves the image up/down.
  - Used to align the visible outline with the wearer’s natural line of sight in the glasses.

### 3.4 Outline Color and Visibility

The app supports a configurable **outline color**, as well as the ability to disable the outline.

- **Outline color**
  - Typical options might include:
    - White
    - Black
    - High-contrast colors (e.g., green, cyan, magenta), configurable in the UI.

- **Transparent / disabled outline**
  - Setting the outline color to a **fully transparent value** (e.g. alpha = 0) effectively **disables** the outline.
  - This can be used for previewing the raw camera feed or for quickly turning off processing.

### 3.5 Behavior on First Launch vs Subsequent Launches

- **First launch behavior**
  - App starts in **STOP mode**.
  - Uses **default settings**, such as:
    - A default camera (e.g. back wide)
    - Standard orientation (no mirror/flip)
    - Default external display mapping (if available)
    - Default outline color (e.g. white) and visibility.
  - May present initial hints or descriptions of the STOP/START modes.

- **Subsequent launches**
  - App still opens in **STOP mode** (for safety and configuration).
  - Previously chosen settings are **restored**, for example:
    - Last-used camera and orientation.
    - Last-known external display layout (view size and offsets).
    - Last-used outline color and threshold parameters.
  - This allows the user to quickly verify previous choices and move to START mode with minimal adjustment.

---

## 4. START Mode (Live Outline Rendering)

**START mode** is the main operational mode of ONA2. In this mode, the app applies real-time image processing to the camera feed and renders the resulting outline image full screen on the external display.

### 4.1 Entering START Mode

- The user switches from **STOP** to **START** (e.g., via a button or control in the UI).
- The current configuration from STOP mode (camera, display mapping, outline color, etc.) is applied.
- The external display shows the **live outline view**.

### 4.2 Gesture Controls Overview

Controls in START mode are based on multitouch gestures on the iPhone screen:

- **Two-finger gestures**:
  - Zoom
  - Aspect ratio adjustments
  - Pan
  - Rotation
- **One-finger gesture** (loop menu):
  - Tap-and-hold + drag gesture that opens a circular/loop menu of parameters.
  - Adjusts:
    - Brightness
    - Contrast
    - Detection threshold
    - Outline width
    - STOP (return to STOP mode)

These gestures **do not** directly draw on the image; instead, they change parameters that affect the rendered outline.

### 4.3 Two-Finger Gestures (View Transform)

**Two fingers** on the screen control the **spatial transformation** of the source image:

- **Pinch (Zoom)**
  - Moving two fingers closer together → **zoom out**.
  - Moving two fingers apart → **zoom in**.
  - Used to adjust how much of the scene appears in the glasses.

- **Spread/squash across one axis (Aspect Ratio)**
  - Uneven stretching in horizontal vs vertical directions can change the effective **aspect ratio**.
  - Helps compensate for optical distortions or preferences in how the image appears in the glasses.

- **Translate (Pan)**
  - Moving both fingers together in the same direction pans the image.
  - Shifts the visible region without changing zoom.

- **Rotate (Rotation)**
  - Rotating two fingers around a central point rotates the image.
  - Useful for correcting any perceived tilt due to how the glasses sit on the user’s head or how the device is held.

All of these transformations are applied to the rendered outline view, not the raw camera buffer.

### 4.4 One-Finger Loop Menu

The **one-finger loop menu** provides a way to adjust processing parameters **without leaving START mode**.

#### 4.4.1 Activation

- Typically activated by a **press-and-hold** or a specific **tap pattern** with one finger.
- Once activated, circular/loop segments around the activation point correspond to different parameters.

#### 4.4.2 Available Menu Options

The loop menu includes the following options:

1. **Brightness**
2. **Contrast**
3. **Detection threshold** (for edges/outline)
4. **Outline width**
5. **STOP** (switch back to STOP mode)

#### 4.4.3 Horizontal and Vertical Swipes

Once a parameter is selected from the loop menu, **horizontal** and **vertical** swipes on the screen adjust its value:

- **Horizontal swipes**
  - Often used for **coarser** or more global changes.
  - Example: swiping right increases brightness; swiping left decreases brightness.

- **Vertical swipes**
  - Often used for **finer** adjustments, secondary aspects, or different sub-ranges.
  - Example: swiping up may slightly increase contrast; swiping down may slightly reduce it.

The exact mapping can be tuned, but the core concept is:

- One finger chooses a parameter from the loop menu.
- Horizontal/vertical motion **while the finger is down** adjusts that parameter.
- Releasing the finger **commits** the new value.

#### 4.4.4 5-Second Persistence Behavior

To prevent accidental or fleeting changes, ONA2 uses a **5-second persistence rule** for parameter adjustments in START mode:

- When you adjust a parameter (e.g., brightness via swipes), the new value is **previewed** immediately.
- If there is **no additional interaction** for approximately **5 seconds**:
  - The current parameter values are **persisted** as the new defaults for the session.
- If you continue to interact (e.g., keep adjusting), the timer resets.

This allows you to experiment with settings, then let them “settle” naturally into persistent values without having to press a separate save button.

---

## 5. Technical Architecture

ONA2 is implemented using a combination of **SwiftUI**, **UIKit**, **AVFoundation**, **Core Image**, and external display APIs.

### 5.1 UI Layer

- **SwiftUI**
  - Main app structure and declarative UI.
  - Screens for STOP and START modes.
  - Bindings for user-adjustable settings (camera, offsets, colors, thresholds, etc.).

- **UIKit touch surface via `UIViewRepresentable`**
  - A custom `UIView` is wrapped using `UIViewRepresentable` so that SwiftUI can host gesture-rich UIKit views.
  - This view:
    - Receives and interprets **multi-touch events** (two-finger and one-finger gestures).
    - Forwards normalized gesture data (zoom factors, pan offsets, etc.) back to SwiftUI via callbacks or bindings.

### 5.2 Camera Capture (AVFoundation)

- Uses **AVCaptureSession** to capture frames from the selected camera.
- Typical setup:

```swift
let session = AVCaptureSession()
session.sessionPreset = .high

let device = AVCaptureDevice.default(.builtInWideAngleCamera,
                                     for: .video,
                                     position: .back)
let input = try AVCaptureDeviceInput(device: device)

if session.canAddInput(input) {
    session.addInput(input)
}

let output = AVCaptureVideoDataOutput()
output.setSampleBufferDelegate(self, queue: captureQueue)

if session.canAddOutput(output) {
    session.addOutput(output)
}

session.startRunning()
```

- Sample buffers are then passed into the **Core Image pipeline**.

### 5.3 Image Processing (Core Image Pipeline)

The outline view is generated via a **Core Image** chain:

- **Brightness and contrast adjustment**
  - `CIColorControls` or similar filters.
- **Edge detection**
  - Sobel-like or other edge detection filters.
  - Thresholding to isolate strong edges (configurable detection threshold).
- **Outline rendering**
  - Converting edges to a thin/variable-width outline.
  - Coloring the outline according to user settings.
  - When outline is disabled (transparent color), pipeline may pass through or reduce to minimal processing.

Example (conceptual) pipeline code snippet:

```swift
let inputImage: CIImage = ... // from camera

let colorControls = CIFilter(name: "CIColorControls")!
colorControls.setValue(inputImage, forKey: kCIInputImageKey)
colorControls.setValue(brightness, forKey: kCIInputBrightnessKey)
colorControls.setValue(contrast,   forKey: kCIInputContrastKey)

let adjusted = colorControls.outputImage!

let edgesFilter = CIFilter(name: "CIEdges")!
edgesFilter.setValue(adjusted, forKey: kCIInputImageKey)
edgesFilter.setValue(edgeIntensity, forKey: kCIInputIntensityKey)

let edgesImage = edgesFilter.outputImage!

// Additional thresholding / width / color logic would be applied here
```

### 5.4 External Display Management (AirPlay / Rokid Max)

- ONA2 monitors available screens using **UIScreen** and related notifications:
  - When an external display appears (AirPlay, cable, etc.), a dedicated window or scene is attached to it.

Conceptual example:

```swift
if let externalScreen = UIScreen.screens.dropFirst().first {
    let externalWindow = UIWindow(frame: externalScreen.bounds)
    externalWindow.screen = externalScreen
    externalWindow.rootViewController = UIHostingController(rootView: OutlineView())
    externalWindow.isHidden = false
}
```

- The outline view is rendered **full screen** on the external display.
- Transformations (zoom, pan, rotation) computed from gestures are applied in this rendering path.

---

## 6. Build & Run Instructions

### 6.1 Prerequisites

- **Xcode**: Latest version that supports **iOS 18 SDK**.
- **iOS device**: iPhone 14 Pro (or similar device running **iOS 18+**).
- **Rokid Max** (or similar AR glasses) that can function as an **external display** via **AirPlay** or cable.

### 6.2 Cloning the Project

Using `git`:

```bash
git clone https://github.com/PedrosaBusquets/ONA2.git
cd ONA2
```

### 6.3 Opening in Xcode

1. Open `ONA2.xcodeproj` or `ONA2.xcworkspace` in **Xcode**.
2. Select your **iOS device** (iPhone 14 Pro or similar) as the run target.
3. Ensure the deployment target is **iOS 18 or later**.

### 6.4 Building and Running

1. Connect your iPhone via USB (or set up wireless debugging).
2. Press **Run** in Xcode to install and launch ONA2 on the device.
3. On the iPhone, go to **Control Center → Screen Mirroring** and connect to **Rokid Max** (or your AR glasses adapter) via **AirPlay** so that it appears as an external display.
4. Launch ONA2 (if not already running):
   - App starts in **STOP mode**.
   - Configure camera, mirroring, display offsets, and outline color.
5. Switch to **START mode**:
   - Verify that the outline view appears on the Rokid Max screen.
   - Use **two-finger gestures** for zoom/pan/rotation.
   - Use the **one-finger loop menu** to tune brightness, contrast, detection threshold, and outline width.

### 6.5 Notes

- For best performance, keep the device cool and avoid other apps heavily using the camera or GPU.
- Long sessions may benefit from external power.

---

## 7. Status and Contributions

This README describes the intended behavior and architecture of **ONAMCORDA GLASSES (ONA2)**. Implementation details may evolve.

Contributions, issues, and suggestions are welcome via GitHub.

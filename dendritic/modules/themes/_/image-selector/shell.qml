import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import QtQuick
import QtQuick.Effects
import QtQuick.Shapes
import QtQuick.Layouts

ShellRoot {
  id: root

  property string rowsB64: Quickshell.env("THEME_SELECTOR_ROWS_B64") || ""
  property string selectionFile: Quickshell.env("THEME_SELECTOR_SELECTION_FILE") || ""
  property string doneFile: Quickshell.env("THEME_SELECTOR_DONE_FILE") || ""
  property string selectedImage: Quickshell.env("THEME_SELECTOR_SELECTED") || ""
  property var imageArray: []
  property int selectedIndex: 0
  property bool opened: false
  property bool imagesLoaded: false

  readonly property color bg: "#1a1a1aee"
  readonly property color accent: "#a7c080"
  readonly property color border: "#a7c080"
  readonly property color dim: "#1a1a1a88"
  readonly property color text: "#d3c6aa"
  readonly property int expandedWidth: 768
  readonly property int expandedHeight: 475
  readonly property int sliceWidth: 108
  readonly property int sliceHeight: 432
  readonly property int sliceSpacing: -30

  Component.onCompleted: {
    if (!rowsB64) return
    try {
      var decoded = Qt.atob(rowsB64)
      var lines = decoded.split("\n")
      var images = []
      var seen = {}
      for (var i = 0; i < lines.length; i++) {
        var line = lines[i]
        if (!line) continue
        var parts = line.split("\t")
        var path = parts[0]
        if (!path) continue
        var fileName = path.split("/").pop()
        if (seen[fileName]) continue
        seen[fileName] = true
        images.push({
          filePath: path,
          fileName: fileName,
          thumbnailPath: parts[1] || path,
          themeName: parts[2] || fileName.replace(/\.[^/.]+$/, "")
        })
      }
      imageArray = images

      if (selectedImage) {
        for (var j = 0; j < images.length; j++) {
          if (images[j].filePath === selectedImage || images[j].themeName === selectedImage) {
            selectedIndex = j
            break
          }
        }
      }

      imagesLoaded = images.length > 0
      opened = imagesLoaded
    } catch (e) {
      console.log("Failed to decode rows:", e)
    }
  }

  function selectAdjacent(dir) {
    var count = imageArray.length
    if (count === 0) return
    var idx = selectedIndex
    for (var i = 0; i < count; i++) {
      idx = (idx + dir + count) % count
      selectedIndex = idx
      return
    }
  }

  function applySelected() {
    if (imageArray.length === 0 || !selectionFile) {
      cancel()
      return
    }
    var themeName = imageArray[selectedIndex].themeName
    applyProc.command = ["bash", "-c", "printf '%s\\n' " + "'" + themeName.replace(/'/g, "'\\''") + "'" + " > " + "'" + selectionFile.replace(/'/g, "'\\''") + "'" + "; : > " + "'" + doneFile.replace(/'/g, "'\\''") + "'"]
    applyProc.running = true
  }

  function cancel() {
    if (doneFile) {
      cancelProc.command = ["bash", "-c", ": > " + "'" + doneFile.replace(/'/g, "'\\''") + "'"]
      cancelProc.running = true
    } else {
      opened = false
      Qt.callLater(function() { Qt.quit() })
    }
  }

  Process {
    id: applyProc
    onExited: {
      root.opened = false
      Qt.callLater(function() { Qt.quit() })
    }
  }

  Process {
    id: cancelProc
    onExited: {
      root.opened = false
      Qt.callLater(function() { Qt.quit() })
    }
  }

  PanelWindow {
    id: panel

    visible: root.opened
    anchors { top: true; bottom: true; left: true; right: true }
    color: "transparent"
    WlrLayershell.namespace: "theme-selector"
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: root.opened ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None
    exclusionMode: ExclusionMode.Ignore

    Rectangle {
      anchors.fill: parent
      visible: root.opened
      color: root.bg
    }

    MouseArea {
      anchors.fill: parent
      enabled: root.opened
      onClicked: root.cancel()
    }

    Item {
      id: card
      visible: root.opened && root.imagesLoaded && root.imageArray.length > 0
      width: Math.min(parent.width - 80, root.expandedWidth + 13 * (root.sliceWidth + root.sliceSpacing) + 40)
      height: root.expandedHeight + 60
      anchors.centerIn: parent

      MouseArea { anchors.fill: parent; onClicked: {} }

      Item {
        id: carousel
        anchors.top: parent.top
        anchors.topMargin: 30
        anchors.bottom: parent.bottom
        anchors.horizontalCenter: parent.horizontalCenter
        width: root.expandedWidth + 13 * (root.sliceWidth + root.sliceSpacing)
        clip: false
        focus: true

        readonly property real itemStep: root.sliceWidth + root.sliceSpacing
        readonly property real previewX: (width - root.expandedWidth) / 2

        Keys.priority: Keys.BeforeItem
        Keys.onPressed: function(event) {
          if (event.key === Qt.Key_Escape) {
            root.cancel()
            event.accepted = true
          } else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
            root.applySelected()
            event.accepted = true
          } else if (event.key === Qt.Key_Left || event.key === Qt.Key_Shift) {
            root.selectAdjacent(-1)
            event.accepted = true
          } else if (event.key === Qt.Key_Right || event.key === Qt.Key_Tab) {
            root.selectAdjacent(1)
            event.accepted = true
          }
        }

        Component.onCompleted: forceActiveFocus()

        Repeater {
          model: root.imageArray.length

          delegate: Item {
            id: item
            required property int index

            readonly property var imageData: root.imageArray[index]
            readonly property string filePath: imageData ? imageData.filePath : ""
            readonly property string thumbnailPath: imageData ? imageData.thumbnailPath : ""

            readonly property int relativeIndex: index - root.selectedIndex
            readonly property bool selected: index === root.selectedIndex
            readonly property bool nearby: Math.abs(relativeIndex) <= 16
            property bool sourceActivated: nearby
            onNearbyChanged: if (nearby) sourceActivated = true

            visible: nearby
            x: selected ? carousel.previewX : (relativeIndex < 0 ? carousel.previewX + relativeIndex * carousel.itemStep : carousel.previewX + root.expandedWidth + root.sliceSpacing + (relativeIndex - 1) * carousel.itemStep)
            width: selected ? root.expandedWidth : root.sliceWidth
            height: selected ? root.expandedHeight : root.sliceHeight
            y: selected ? 0 : (root.expandedHeight - root.sliceHeight) / 2
            z: selected ? 100 : 50 - Math.min(Math.abs(relativeIndex), 40)

            readonly property real skAbs: 28
            readonly property real topLeft: skAbs
            readonly property real topRight: width
            readonly property real bottomRight: width - skAbs
            readonly property real bottomLeft: 0

            Item {
              id: maskShape
              anchors.fill: parent
              visible: false
              layer.enabled: true

              Shape {
                anchors.fill: parent
                antialiasing: true
                preferredRendererType: Shape.CurveRenderer
                ShapePath {
                  fillColor: "white"
                  strokeColor: "transparent"
                  startX: item.topLeft; startY: 0
                  PathLine { x: item.topRight; y: 0 }
                  PathLine { x: item.bottomRight; y: item.height }
                  PathLine { x: item.bottomLeft; y: item.height }
                  PathLine { x: item.topLeft; y: 0 }
                }
              }
            }

            Item {
              anchors.fill: parent
              layer.enabled: true
              layer.smooth: true
              layer.effect: MultiEffect {
                maskEnabled: true
                maskSource: maskShape
                maskThresholdMin: 0.3
                maskSpreadAtMin: 0.3
              }

              Image {
                id: image
                anchors.fill: parent
                source: item.sourceActivated && item.thumbnailPath ? "file://" + item.thumbnailPath : ""
                fillMode: Image.PreserveAspectCrop
                asynchronous: false
                cache: true
                smooth: true
              }

              Rectangle {
                anchors.fill: parent
                color: item.selected ? "transparent" : root.dim
              }
            }

            Shape {
              anchors.fill: parent
              antialiasing: true
              preferredRendererType: Shape.CurveRenderer
              ShapePath {
                fillColor: "transparent"
                strokeColor: item.selected ? root.border : "#555555"
                strokeWidth: item.selected ? 3 : 1
                startX: item.topLeft; startY: 0
                PathLine { x: item.topRight; y: 0 }
                PathLine { x: item.bottomRight; y: item.height }
                PathLine { x: item.bottomLeft; y: item.height }
                PathLine { x: item.topLeft; y: 0 }
              }
            }

            MouseArea {
              anchors.fill: parent
              cursorShape: Qt.PointingHandCursor
              onClicked: item.selected ? root.applySelected() : root.selectedIndex = item.index
            }
          }
        }
      }

      Text {
        visible: root.imageArray.length > 0
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 10
        anchors.horizontalCenter: carousel.horizontalCenter
        text: root.imageArray[root.selectedIndex].themeName
        color: root.text
        style: Text.Outline
        styleColor: "#88000000"
        font.pixelSize: 16
        font.weight: Font.DemiBold
        horizontalAlignment: Text.AlignHCenter
        elide: Text.ElideRight
        width: root.expandedWidth
      }
    }
  }
}

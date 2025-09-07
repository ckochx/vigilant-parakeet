// If you want to use Phoenix channels, run `mix help phx.gen.channel`
// to get started and then uncomment the line below.
// import "./user_socket.js"

// You can include dependencies in two ways.
//
// The simplest option is to put them in assets/vendor and
// import them using relative paths:
//
//     import "../vendor/some-package.js"
//
// Alternatively, you can `npm install some-package --prefix assets` and import
// them using a path starting with the package name:
//
//     import "some-package"
//
// If you have dependencies that try to import CSS, esbuild will generate a separate `app.css` file.
// To load it, simply add a second `<link>` to your `root.html.heex` file.

// Include phoenix_html to handle method=PUT/DELETE in forms and buttons.
import "phoenix_html"
// Establish Phoenix Socket and LiveView configuration.
import {Socket} from "phoenix"
import {LiveSocket} from "phoenix_live_view"
import {hooks as colocatedHooks} from "phoenix-colocated/gearflow"
import topbar from "../vendor/topbar"

// Speech Recognition Hook
const SpeechRecognition = {
  mounted() {
    this.recognition = null
    this.mediaRecorder = null
    this.audioChunks = []
    this.isRecording = false

    // Handle speech recognition events from server
    this.handleEvent("start-speech-recognition", () => {
      this.startSpeechRecognition()
    })

    // Handle voice recording events from server
    this.handleEvent("start-voice-recording", () => {
      this.toggleVoiceRecording()
    })

    // Add click handler for the voice recording button
    this.voiceButton = this.el.querySelector('[phx-click="start-voice-recording"]')
    if (this.voiceButton) {
      this.voiceButton.addEventListener('click', (e) => {
        e.preventDefault()
        this.toggleVoiceRecording()
      })
    }
  },

  startSpeechRecognition() {
    if (!('webkitSpeechRecognition' in window) && !('SpeechRecognition' in window)) {
      alert('Speech recognition not supported in this browser')
      return
    }

    const SpeechRecognition = window.SpeechRecognition || window.webkitSpeechRecognition
    this.recognition = new SpeechRecognition()
    
    this.recognition.continuous = false
    this.recognition.interimResults = false
    this.recognition.lang = 'en-US'

    this.recognition.onstart = () => {
      console.log('Speech recognition started')
    }

    this.recognition.onresult = (event) => {
      const transcript = event.results[0][0].transcript
      console.log('Speech result:', transcript)
      
      // Send result back to LiveView
      this.pushEvent("speech-result", {text: transcript})
    }

    this.recognition.onerror = (event) => {
      console.error('Speech recognition error:', event.error)
    }

    this.recognition.onend = () => {
      console.log('Speech recognition ended')
    }

    this.recognition.start()
  },

  toggleVoiceRecording() {
    if (this.isRecording) {
      this.stopVoiceRecording()
    } else {
      this.startVoiceRecording()
    }
  },

  startVoiceRecording() {
    if (!navigator.mediaDevices || !navigator.mediaDevices.getUserMedia) {
      alert('Voice recording not supported in this browser')
      return
    }

    if (this.mediaRecorder && this.mediaRecorder.state === 'recording') {
      return
    }

    navigator.mediaDevices.getUserMedia({ audio: true })
      .then(stream => {
        this.mediaRecorder = new MediaRecorder(stream)
        this.audioChunks = []
        this.isRecording = true
        this.updateRecordingUI()

        this.mediaRecorder.ondataavailable = (event) => {
          if (event.data.size > 0) {
            this.audioChunks.push(event.data)
          }
        }

        this.mediaRecorder.onstop = () => {
          const audioBlob = new Blob(this.audioChunks, { type: 'audio/webm' })
          this.handleAudioBlob(audioBlob)
          stream.getTracks().forEach(track => track.stop())
          this.isRecording = false
          this.updateRecordingUI()
        }

        this.mediaRecorder.start()
        console.log('Voice recording started')

        // Auto-stop after 30 seconds
        setTimeout(() => {
          if (this.mediaRecorder && this.mediaRecorder.state === 'recording') {
            this.stopVoiceRecording()
          }
        }, 30000)
      })
      .catch(error => {
        console.error('Error accessing microphone:', error)
        alert('Could not access microphone')
        this.isRecording = false
        this.updateRecordingUI()
      })
  },

  stopVoiceRecording() {
    if (this.mediaRecorder && this.mediaRecorder.state === 'recording') {
      this.mediaRecorder.stop()
      console.log('Voice recording stopped')
    }
  },

  updateRecordingUI() {
    if (this.voiceButton) {
      if (this.isRecording) {
        this.voiceButton.innerHTML = '⏹️ Stop Recording'
        this.voiceButton.classList.remove('bg-red-100', 'text-red-700', 'hover:bg-red-200')
        this.voiceButton.classList.add('bg-red-500', 'text-white', 'hover:bg-red-600', 'animate-pulse')
      } else {
        this.voiceButton.innerHTML = '🎙️ Record Voice Memo'
        this.voiceButton.classList.remove('bg-red-500', 'text-white', 'hover:bg-red-600', 'animate-pulse')
        this.voiceButton.classList.add('bg-red-100', 'text-red-700', 'hover:bg-red-200')
      }
    }
  },

  handleAudioBlob(blob) {
    // Create a file-like object and trigger upload
    const file = new File([blob], `voice_memo_${Date.now()}.webm`, { type: 'audio/webm' })
    
    // Find the file input and simulate file selection
    const fileInput = this.el.querySelector('input[type="file"]')
    if (fileInput) {
      // Create a custom file list
      const dt = new DataTransfer()
      dt.items.add(file)
      fileInput.files = dt.files
      
      // Trigger change event to notify LiveView
      fileInput.dispatchEvent(new Event('change', { bubbles: true }))
    }
  },


  destroyed() {
    if (this.recognition) {
      this.recognition.stop()
    }
    if (this.mediaRecorder && this.mediaRecorder.state === 'recording') {
      this.stopVoiceRecording()
    }
  }
}

const hooks = {
  ...colocatedHooks,
  SpeechRecognition
}

const csrfToken = document.querySelector("meta[name='csrf-token']").getAttribute("content")
const liveSocket = new LiveSocket("/live", Socket, {
  longPollFallbackMs: 2500,
  params: {_csrf_token: csrfToken},
  hooks: hooks,
})

// Show progress bar on live navigation and form submits
topbar.config({barColors: {0: "#29d"}, shadowColor: "rgba(0, 0, 0, .3)"})
window.addEventListener("phx:page-loading-start", _info => topbar.show(300))
window.addEventListener("phx:page-loading-stop", _info => topbar.hide())

// connect if there are any LiveViews on the page
liveSocket.connect()

// expose liveSocket on window for web console debug logs and latency simulation:
// >> liveSocket.enableDebug()
// >> liveSocket.enableLatencySim(1000)  // enabled for duration of browser session
// >> liveSocket.disableLatencySim()
window.liveSocket = liveSocket

// The lines below enable quality of life phoenix_live_reload
// development features:
//
//     1. stream server logs to the browser console
//     2. click on elements to jump to their definitions in your code editor
//
if (process.env.NODE_ENV === "development") {
  window.addEventListener("phx:live_reload:attached", ({detail: reloader}) => {
    // Enable server log streaming to client.
    // Disable with reloader.disableServerLogs()
    reloader.enableServerLogs()

    // Open configured PLUG_EDITOR at file:line of the clicked element's HEEx component
    //
    //   * click with "c" key pressed to open at caller location
    //   * click with "d" key pressed to open at function component definition location
    let keyDown
    window.addEventListener("keydown", e => keyDown = e.key)
    window.addEventListener("keyup", e => keyDown = null)
    window.addEventListener("click", e => {
      if(keyDown === "c"){
        e.preventDefault()
        e.stopImmediatePropagation()
        reloader.openEditorAtCaller(e.target)
      } else if(keyDown === "d"){
        e.preventDefault()
        e.stopImmediatePropagation()
        reloader.openEditorAtDef(e.target)
      }
    }, true)

    window.liveReloader = reloader
  })
}


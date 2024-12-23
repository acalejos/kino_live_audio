import React, { useEffect, useState } from "react";
import { RiMicLine } from "@remixicon/react";

export default function App({ ctx, payload }) {
  const [isRecording, setIsRecording] = useState(false);
  const [audioContext, setAudioContext] = useState(null);
  const [pcmNode, setPcmNode] = useState(null);
  const [mediaStreamSource, setMediaStreamSource] = useState(null);

  // Initialize AudioContext and AudioWorklet
  useEffect(() => {
    const initAudioContext = async () => {
      if (!window.AudioContext) return;
      const context = new AudioContext({ sampleRate: payload.sampleRate });

      await context.audioWorklet.addModule("./pcm-processor.js");
      const node = new AudioWorkletNode(context, "pcm-processor", {
        processorOptions: { chunkSize: payload.chunkSize },
      });

      node.port.onmessage = (event) => {
        const audioData = new Float32Array(event.data);
        console.log("Received chunked PCM data", audioData);
        ctx.pushEvent("audio_chunk", event.data);
      };

      setAudioContext(context);
      setPcmNode(node);
    };

    initAudioContext();
  }, []);

  const startRecording = async () => {
    if (!audioContext || isRecording) return;

    const stream = await navigator.mediaDevices.getUserMedia({ audio: true });
    const source = audioContext.createMediaStreamSource(stream);
    source.connect(pcmNode);
    pcmNode.connect(audioContext.destination); // Necessary but doesn't output sound to speakers

    ctx.pushEvent("start_audio");
    setMediaStreamSource(source);
    setIsRecording(true);
  };

  const stopRecording = () => {
    if (!audioContext || !isRecording) return;

    // Disconnect the nodes and stop the media stream
    if (mediaStreamSource) {
      mediaStreamSource.disconnect();
      pcmNode.disconnect();
      const tracks = mediaStreamSource.mediaStream.getTracks();
      tracks.forEach((track) => track.stop());
    }

    ctx.pushEvent("stop_audio");
    setMediaStreamSource(null);
    setIsRecording(false);
  };

  return (
    <div>
      {!isRecording && <RecordButton />}
      {isRecording && <StopButton />}
    </div>
  );

  function RecordButton() {
    return (
      <button
        onClick={startRecording}
        className="button-base button-gray border-transparent py-2 px-4 inline-flex text-gray-500"
      >
        <RiMicLine
          className="text-lg leading-none mr-2"
          width="18"
          height="18"
        />
        <span>Record</span>
      </button>
    );
  }

  function StopButton() {
    return (
      <button
        onClick={stopRecording}
        class="button-base button-gray border-transparent py-2 px-4 inline-flex text-gray-500 items-center"
      >
        <span class="mr-2 flex h-3 w-3 relative">
          <span class="animate-ping absolute inline-flex h-full w-full rounded-full bg-gray-400 opacity-75"></span>
          <span class="relative inline-flex rounded-full h-3 w-3 bg-gray-500"></span>
        </span>
        <span>Stop recording</span>
      </button>
    );
  }
}

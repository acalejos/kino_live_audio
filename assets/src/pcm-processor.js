// pcm-processor.js
class PCMProcessor extends AudioWorkletProcessor {
  constructor(options) {
    super();
    this.sampleBuffer = [];
    this.chunkSize = options.processorOptions.chunkSize || 16000;
  }

  process(inputs) {
    const input = inputs[0];
    if (input.length > 0) {
      const inputData = input[0];
      for (let i = 0; i < inputData.length; ++i) {
        this.sampleBuffer.push(inputData[i]);
        if (this.sampleBuffer.length >= this.chunkSize) {
          this.port.postMessage(this.sampleBuffer.slice(0, this.chunkSize));
          this.sampleBuffer = this.sampleBuffer.slice(this.chunkSize);
        }
      }
    }
    return true;
  }
}

registerProcessor("pcm-processor", PCMProcessor);

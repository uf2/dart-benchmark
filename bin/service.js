'use strict'

const path = require('path')
const work = require(path.join(__dirname, './work.js'))
const {workerData, parentPort} = require('worker_threads')

;(function runJob() {
  for (let i = 0; i < workerData; i++) {
    work.someUsefulWork(i)
  }
  parentPort.postMessage(null)
})()


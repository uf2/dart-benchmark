'use strict'

const path = require('path')
const work = require(path.join(__dirname, './work.js'))
const {Worker} = require('worker_threads')

const CHILDREN = require('os').cpus().length
const POINTS_PER_CHILD = 100000

function main() {
  console.log('Doing it the slow (single-process) way...')
  const begin1 = +new Date()
  for (let i = 0; i < CHILDREN * POINTS_PER_CHILD; i++) {
    work.someUsefulWork(i)
  }
  const difference1 = +new Date() - begin1
  console.log(`slow way took: ${difference1} ms`)

  console.log('Doing it the fast (multi-process) way...')
  let ret = CHILDREN
  const begin2 = +new Date()
  for (let i = 0; i < CHILDREN; i++) {
    const service = new Worker(path.join(__dirname, './service.js'), {workerData: POINTS_PER_CHILD})
    service.on('message', function () {
      --ret
      service.terminate()
      if (ret === 0) {
        const difference2 = +new Date() - begin2
        console.log(`fast way took: ${difference2} ms`)
        console.log((difference1 / difference2).toFixed(2), 'faster')
      }
    })
  }
}

main()







'use strict'

const crypto = require('crypto')

function someUsefulWork(i) {
  return crypto.createHash('sha256')
    .update(i.toString())
    .digest('hex')
}

module.exports = {someUsefulWork}
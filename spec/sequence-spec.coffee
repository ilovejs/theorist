Sequence = require '../src/sequence'

isEqual = require 'tantamount'

describe "Sequence", ->
  [sequence, changes] = []

  beforeEach ->
    sequence = Sequence("abcdefg".split('')...)
    changes = []
    sequence.on 'changed', (change) -> changes.push(change)

  it "reports itself as an instance of both Sequence and Array", ->
    expect(sequence instanceof Sequence).toBe true
    expect(sequence instanceof Array).toBe true

  describe "property access via ::[]", ->
    it "allows sequence elements to be read via numeric keys", ->
      expect(sequence[0]).toBe 'a'
      expect(sequence['1']).toBe 'b'

    it "updates the sequence and emits 'changed' events when assigning elements via numeric keys", ->
      sequence[2] = 'C'
      expect(sequence).toEqual "abCdefg".split('')
      expect(changes).toEqual [{
        index: 2
        removedValues: ['c']
        insertedValues: ['C']
      }]

      changes = []
      sequence[9] = 'X'
      expect(sequence).toEqual "abCdefg".split('').concat([undefined, undefined, 'X'])
      expect(changes).toEqual [{
        index: 7
        removedValues: []
        insertedValues: [undefined, undefined, 'X']
      }]

    it "allows non-numeric properties to be accessed via non-numeric keys", ->
      sequence.foo = "bar"
      expect(sequence.foo).toBe "bar"

  describe "::length", ->
    it "returns the current length of the sequence", ->
      expect(sequence.length).toBe 7

    describe "when assigning a value shorter than the current length", ->
      it "truncates the sequence and emits a 'changed' event", ->
        sequence.length = 4
        expect(sequence).toEqual "abcd".split('')
        expect(changes).toEqual [{
          index: 4
          removedValues: ['e', 'f', 'g']
          insertedValues: []
        }]

    describe "when assigning a value greater than the current length", ->
      it "expands the sequence and emits a 'changed' event'", ->
        sequence.length = 9
        expect(sequence).toEqual "abcdefg".split('').concat([undefined, undefined])
        expect(changes).toEqual [{
          index: 7
          removedValues: []
          insertedValues: [undefined, undefined]
        }]

  describe "iteration", ->
    it "can iterate over the sequence with standard coffee-script syntax", ->
      values = (value for value in sequence)
      expect(values).toEqual sequence

  describe "::splice", ->
    it "splices the sequence and emits a 'changed' event", ->
      result = sequence.splice(3, 2, 'D', 'E', 'F')
      expect(result).toEqual ['d', 'e']
      expect(sequence).toEqual "abcDEFfg".split('')
      expect(changes).toEqual [{
        index: 3
        removedValues: ['d', 'e']
        insertedValues: ['D', 'E', 'F']
      }]

  describe "::push", ->
    it "pushes to the sequence and emits a 'changed' event", ->
      result = sequence.push('X', 'Y', 'Z')
      expect(result).toBe 10
      expect(sequence).toEqual "abcdefgXYZ".split('')
      expect(changes).toEqual [{
        index: 7
        removedValues: []
        insertedValues: ['X', 'Y', 'Z']
      }]

  describe "::pop", ->
    it "pops the sequence and emits a 'changed' event", ->
      result = sequence.pop()
      expect(result).toBe 'g'
      expect(sequence).toEqual "abcdef".split('')
      expect(changes).toEqual [{
        index: 6
        removedValues: ['g']
        insertedValues: []
      }]

  describe "::unshift", ->
    it "unshifts to the sequence and emits a 'changed' event", ->
      result = sequence.unshift('X', 'Y', 'Z')
      expect(result).toBe 10
      expect(sequence).toEqual "XYZabcdefg".split('')
      expect(changes).toEqual [{
        index: 0
        removedValues: []
        insertedValues: ['X', 'Y', 'Z']
      }]

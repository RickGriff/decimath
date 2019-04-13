const makeBN = require ('../scripts/makeBN.js');
const BN = require('bn.js');
const Decimal = require('decimal.js');

// Tests for the MakeBN module
describe('MakeBN18', function() {
  let a = makeBN.makeBN18('2')
  let b = makeBN.makeBN18('0.000000000000000001')
  let c = makeBN.makeBN18('100000000000000000000000.9')


  describe('input has <= 18 decimal places', function() {
    it('should create a BN object', function(){
      assert.instanceOf(a, BN);
      assert.instanceOf(b, BN);
      assert.instanceOf(c, BN);
    });

    it('should return an integer representation of an 18 decimal place number', function(){
      assert.equal(a.toString(), '2000000000000000000')
      assert.equal(b.toString(), '1')
      assert.equal(c.toString(), '100000000000000000000000900000000000000000')
    })
  });

  describe('input has > 18 decimal places', function() {
    it('should throw', function() {
      expect(() => makeBN.makeBN18('0.0000000000000000009')).to.throw("argument must have <= 18 decimal places")
    });
  });
});

describe('MakeBN38', function() {
  let a = makeBN.makeBN38('2')
  let b = makeBN.makeBN38('0.00000000000000000000000000000000000001')
  let c = makeBN.makeBN38('100000000000000000000000.9')

  describe('input has <= 38 decimal places', function() {
    it('should create a BN object', function(){
      assert.instanceOf(a, BN);
      assert.instanceOf(b, BN);
      assert.instanceOf(c, BN);
    });

    it('should return an integer representation of an 38 decimal place number', function(){
      assert.equal(a.toString(), '200000000000000000000000000000000000000')
      assert.equal(b.toString(), '1')
      assert.equal(c.toString(), '10000000000000000000000090000000000000000000000000000000000000')
    })
  });

  describe('input has > 38 decimal places', function() {
    it('should throw', function() {
      expect(() => makeBN.makeBN38('0.000000000000000000000000000000000000009')).to.throw("argument must have <= 38 decimal places")
    });
  });
});


describe('makeDecimal38', function() {
  let a;
  let b;
  let c;
  let dec;

  it ('Returns a Decimal', function () {
    a = makeBN.makeBN38('1');
    dec = makeBN.makeDecimal38(a);
    assert.instanceOf(dec, Decimal);
  });

  it ('Makes Decimals from basic BNs', function () {
    a = makeBN.makeBN38('0')
    dec = makeBN.makeDecimal38(a)
    assert.equal(dec.valueOf(), 0)

    a = makeBN.makeBN38('1')
    dec = makeBN.makeDecimal38(a)
    assert.equal(dec.valueOf(), 1)
  });

  it ('Makes Decimals from BNs in range [0,1]', function () {
    a = makeBN.makeBN38('0.1')
    dec = makeBN.makeDecimal38(a)
    assert.equal(dec.valueOf(), 0.1)

    // BN (0.00054321)
    a = makeBN.makeBN38('5.4321')
    dec = makeBN.makeDecimal38(a)
    assert.equal(dec.valueOf(), 5.4321)

    // BN(500000000000000000000)
    a = makeBN.makeBN38('0.00000000000000000000000000000000000005')
    dec = makeBN.makeDecimal38(a)
    assert.equal(dec.valueOf(), 0.00000000000000000000000000000000000005)
  });

  it ('Makes Decimals from BNs in range [1,10]', function () {
    a = makeBN.makeBN38('1.5')
    dec = makeBN.makeDecimal38(a)
    assert.equal(dec.valueOf(), 1.5)

    a = makeBN.makeBN38('5.098093869086')
    dec = makeBN.makeDecimal38(a)

    assert.equal(dec.valueOf(), 5.098093869086)

    a = makeBN.makeBN38('9.876543219876543219876543219876543219')
    dec = makeBN.makeDecimal38(a)
    assert.equal(dec.valueOf(), 9.876543219876543219876543219876543219)
  });

  it ('Makes Decimals from BNs > 10', function () {
    a = makeBN.makeBN38('1000')
    dec = makeBN.makeDecimal38(a)
    assert.equal(dec.valueOf(), 1000)

    a = makeBN.makeBN38('123456789.987654321')
    dec = makeBN.makeDecimal38(a)
    assert.equal(dec.valueOf(), 123456789.987654321)
  });
});

describe('makeDecimal18', function() {
  let a;
  let b;
  let c;
  let dec;

  it ('Returns a Decimal', function () {
    a = makeBN.makeBN18('1');
    dec = makeBN.makeDecimal18(a);
    assert.instanceOf(dec, Decimal);
  });

  it ('Makes Decimals from basic BNs', function () {
    a = makeBN.makeBN18('0')
    dec = makeBN.makeDecimal18(a)
    assert.equal(dec.valueOf(), 0)

    a = makeBN.makeBN18('1')
    dec = makeBN.makeDecimal18(a)
    assert.equal(dec.valueOf(), 1)
  });

  it ('Makes Decimals from BNs in range [0,1]', function () {
    a = makeBN.makeBN18('0.1')
    dec = makeBN.makeDecimal18(a)
    assert.equal(dec.valueOf(), 0.1)

    // BN (0.00054321)
    a = makeBN.makeBN18('5.4321')
    dec = makeBN.makeDecimal18(a)
    assert.equal(dec.valueOf(), 5.4321)

    // BN(500000000000000000000)
    a = makeBN.makeBN18('0.000000000000000005')
    dec = makeBN.makeDecimal18(a)
    assert.equal(dec.valueOf(), 0.000000000000000005)
  });

  it ('Makes Decimals from BNs in range [1,10]', function () {
    a = makeBN.makeBN18('1.5')
    dec = makeBN.makeDecimal18(a)
    assert.equal(dec.valueOf(), 1.5)

    a = makeBN.makeBN18('5.098093869086')
    dec = makeBN.makeDecimal18(a)

    assert.equal(dec.valueOf(), 5.098093869086)

    a = makeBN.makeBN18('9.876543219876543219')
    dec = makeBN.makeDecimal18(a)
    assert.equal(dec.valueOf(), 9.876543219876543219)
  });

  it ('Makes Decimals from BNs > 10', function () {
    a = makeBN.makeBN18('1000')
    dec = makeBN.makeDecimal18(a)
    assert.equal(dec.valueOf(), 1000)

    a = makeBN.makeBN18('123456789.987654321')
    dec = makeBN.makeDecimal18(a)
    assert.equal(dec.valueOf(), 123456789.987654321)
  });
});

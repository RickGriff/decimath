const makeBN = require('../scripts/makeBN.js');
const BN = require('bn.js');

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

  describe('input has > 38 decimal places', function() {
    it('should throw', function() {
      expect(() => makeBN.makeBN18('0.0000000000000000009')).to.throw("makeBigNum18 argument must have <= 18 decimal places")
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
      expect(() => makeBN.makeBN38('0.000000000000000000000000000000000000009')).to.throw("makeBigNum38 argument must have <= 38 decimal places")
    });
  });
});

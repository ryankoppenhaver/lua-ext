local sx = require('stringx')

describe("String extension library", function()
    describe('escape_pattern', function()
        it('should properly escape strings', function()
            assert.are.equal(sx.escape_pattern('%asdf'), '%%asdf')
        end)
    end)

    describe('isalpha', function()
        it('should detect alphanumeric strings', function()
            assert.is_true(sx.isalpha('asdfASDF'))
        end)

        it('should return false for others', function()
            assert.is_false(sx.isalpha('asdf1'))
        end)
    end)

    describe('shorten', function()
        it('should not change short strings', function()
            assert.are.equals(sx.shorten('foo', 10), 'foo')
        end)

        it('should shorten to just dots', function()
            assert.are.equals(sx.shorten('bar', 0), '')
            assert.are.equals(sx.shorten('bar', 1), '.')
            assert.are.equals(sx.shorten('bar', 2), '..')
        end)

        it('should shorten long strings', function()
            assert.are.equals(sx.shorten('foobar123', 6), 'foo...')
        end)

        it('should shorten in reverse properly', function()
            assert.are.equals(sx.shorten('foobar123', 6, true), '...123')
        end)
    end)


end)

module('trim-testcase', lunit.testcase, package.seeall)

setup =
	function ()
		require('setup-test')
		require('string-interp')
	end

test_singular_interp =
	function ()
		assert_equal('hello world',            'hello %s'      % 'world'                       )
		assert_equal('parenthesis are a must', '%s are a must' % (true and 'parenthesis' or ''))
	end

test_multiple_interp =
	function ()
		assert_equal('hello world', 'hello %s' % { 'world'       })
		assert_equal('a b c',       '%s %s %s' % { 'a', 'b', 'c' })
	end

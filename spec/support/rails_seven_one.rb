# frozen_string_literal: true

require "active_support/testing/assertions"

module ActiveSupport
  module Testing
    module Assertions
      # Assertion that the block should not raise an exception.
      #
      # Passes if evaluated code in the yielded block raises no exception.
      #
      #   assert_nothing_raised do
      #     perform_service(param: 'no_exception')
      #   end
      def assert_nothing_raised
        yield # .tap { debugger ; assert(true) }
      rescue => error
        raise Minitest::UnexpectedError.new(error)
      end
    end
  end
end if Rails.version > '7.1'

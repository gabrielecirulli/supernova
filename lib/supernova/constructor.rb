module Supernova

  # Creates a star from a {Supernova.create} call.
  class Constructor

    # Initialize the constructor.
    #
    # @param options [Hash] the definition of the star.  It should
    #   be a single key-value pair, with the first key being the
    #   type of star, and the first value being the name of the
    #   star.
    # @yield for the construction of the new Star.
    # @example
    #   Constructor.new(some_star: :another_star) do
    #     on :some_event do; end
    #   end.create # => Supernova::Star/SomeStar.another_star
    def initialize(options, &block)
      @options = options
      @block = block
    end

    # Modifies an already existing star if it exists, or creates it
    # if it doesn't.
    #
    # @raise [NoStarError] when the star type couldn't be found.
    # @return [Class] a subclass of the star type.
    def modify_or_create
      star_type = Star.types[data[:type]]

      raise NoStarError,
        "Could not find star type #{data[:type]}." unless star_type

      if Star.stars[data[:type]][data[:as]]
        Star.stars[data[:type]][data[:as]].class_exec &@block
        Star.stars[data[:type]][data[:as]]
      else
        new_star = Class.new(star_type)
        new_star.as   = data[:as]
        new_star.type = data[:type]
        new_star.class_exec &@block

        new_star.required_platforms = data[:required_platforms]
        Star.stars[data[:type]][data[:as]] = new_star
      end
    end

    # Returns information about the star, like the type, the required
    # platforms, and what it's named.
    #
    # @return [Hash<Symbol, Object>]
    def data
      @_data ||= {
        :as   => @options.values.first,
        :type => @options.keys.first,
        :required_platforms => [@options[:requires]].flatten.compact
      }
    end

  end
end

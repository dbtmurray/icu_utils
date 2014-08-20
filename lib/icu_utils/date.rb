module ICU
  # Reproduce some of the functionality of validates_timeliness, a gem no longer maintained.
  class Date
    attr_reader :date, :reasons

    def initialize(date, constraints={})
      @reasons = []
      if @date = to_date(date)
        @constraints = constraints.each_with_object({}) do |(k,v), h|
          if %i[after on_or_after before on_or_before].include?(k)
            unless h[k] = to_date(v)
              raise ArgumentError.new("invalid date specified for #{k} constraint")
            end
          else
            raise ArgumentError.new("invalid date constraint #{k}")
          end
        end
      else
        @reasons.push "errors.messages.invalid_date"
      end
    end

    def valid?
      valid = true
      if @date
        if valid && @constraints[:after] && @date <= @constraints[:after]
          valid = false
          @reasons.push "errors.messages.after"
          @reasons.push restriction: @constraints[:after].to_s
        end
        if valid && @constraints[:before] && @date >= @constraints[:before]
          valid = false
          @reasons.push "errors.messages.before"
          @reasons.push restriction: @constraints[:before].to_s
        end
        if valid && @constraints[:on_or_after] && @date < @constraints[:on_or_after]
          valid = false
          @reasons.push "errors.messages.on_or_after"
          @reasons.push restriction: @constraints[:on_or_after].to_s
        end
        if valid && @constraints[:on_or_before] && @date > @constraints[:on_or_before]
          valid = false
          @reasons.push "errors.messages.on_or_before"
          @reasons.push restriction: @constraints[:on_or_before].to_s
        end
      else
        valid = false
      end
      valid
    end

    private

    def to_date(thing)
      thing = thing.call if thing.respond_to?(:call)
      if thing.is_a?(Date)
        thing.dup
      elsif thing.to_s.downcase == "today"
        thing = ::Date.today
      else
        thing = ::Date.parse(thing.to_s)
      end
      thing
    rescue
      nil
    end
  end
end

module Timely
  # Uses Date.current to be more accurate for Rails applications
  def self.current_date
    ::Date.respond_to?(:current) ? ::Date.current : ::Date.today
  end


  module ActionViewHelpers
    module FormTagHelper
      def calendar_tag(name, value = Timely.current_date, *args)
        options = args.extract_options!

        date_format = '%d-%m-%Y'
        value = value.strftime(date_format) if value.respond_to?(:day)

        name = name.to_s if name.is_a?(Symbol)

        options[:id] = options[:id] || name.gsub(/\]$/, '').gsub(/\]\[/, '[').gsub(/[\[\]]/, '_')

        options[:class] = options[:class].split(' ') if options[:class].is_a?(String)
        options[:class] ||= []
        options[:class] += %w(datepicker input-small)

        options[:size] ||= 10
        options[:maxlength] ||= 10

        tag(:input, options.merge(:name => name, :type => 'text', :value => value)).html_safe
      end
    end


    module DateHelper
      def calendar(object_name, method, options = {})
        value = options[:object] || Timely.current_date
        calendar_tag("#{object_name}[#{method}]", value, options.merge(:id => "#{object_name}_#{method}"))
      end
    end

    module FormBuilder
      def calendar(method, options = {})
        @template.calendar(@object_name, method, options.merge(:object => @object.send(method)))
      end
    end
  end
end

if defined?(ActionView)
  ActionView::Base.send :include, Timely::ActionViewHelpers::FormTagHelper
  ActionView::Base.send :include, Timely::ActionViewHelpers::DateHelper
  ActionView::Helpers::FormBuilder.send :include, Timely::ActionViewHelpers::FormBuilder
end
module HappyPlace
  module Controller
    extend ActiveSupport::Concern

    # included do
    #   # anything you would want to do in every controller, for example: add a class attribute
    #   class_attribute :class_attribute_available_on_every_controller, instance_writer: false
    # end

    # module ClassMethods
    #   # notice: no self.method_name here, because this is being extended because ActiveSupport::Concern was extended

    # end

    # instance methods to go on every controller go here
    def js(js_class: nil, function: nil, partials: {}, args: {})
      class_and_function = build_class_and_function(js_class, function)
      built_args = build_args(partials, args)
      case request.format.to_sym
      when :js
        render js: class_and_function + built_args
      when :html
        render
        response_body = response.body
        before_body_end_index = response_body.rindex('</body>')

        before_body = response_body[0, before_body_end_index].html_safe
        after_body = response_body[before_body_end_index..-1].html_safe

        response.body = before_body + auto_exec_function(class_and_function, built_args).html_safe + after_body
      end
    end

    def build_class_and_function(js_class, function)
      js_class ||= self.class.name.gsub("::", ".")
      function ||= action_name
      [js_class, function].join(".")
    end

    def build_args(partials, args)
      if partials.present?
        built_args = "({" +
          (build_partials_string(partials) + hash_to_js_args(args)).join(", ") +
          "});"
      else
        built_args = "({" + hash_to_js_args(args).join(", ") + "});"
      end
    end

    def auto_exec_function(class_and_function, args)
      "<script type='application/javascript'>jQuery(document).ready(function($) {" + render_to_string(js: class_and_function + args) + "});</script>"
    end

    def hash_to_js_args(args)
      js_args = []

      args.each_pair do |k, v|
        js_args << (k.to_s + ": " + "'#{v}'")
      end
      js_args
    end

    def build_partials_string(partials)
      partials_strings = []
      partials.each_pair do |k, v|
        partials_strings << (k.to_s + ": " + "'#{(render_to_string partial: v).gsub("\n", "")}'")
      end
      partials_strings
    end

  end
end

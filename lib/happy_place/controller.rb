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
    def js(js_class: nil, function: nil, partial: nil, args: {})
      return unless [:js, :html].include?(request.format.to_sym)

      js_class ||= self.class.name.gsub("::", ".")
      function ||= action_name

      if partial.present?
        appendable = (render_to_string partial: partial).gsub("\n", "")
        built_args = "({" + (["partial: '#{appendable}'"] + hash_to_js_args(args)).join(", ") + "});"
      else
        built_args = "({" + hash_to_js_args(args).join(", ") + "});"
      end

      class_function = [js_class, function].join(".")
      if request.format.to_sym == :js
        render js: class_function + built_args
      elsif request.format.to_sym == :html
        render
        response_body = response.body
        before_body_end_index = response_body.rindex('</body>')

        if before_body_end_index.present?
          before_body = response_body[0, before_body_end_index].html_safe
          after_body = response_body[before_body_end_index..-1].html_safe

          response.body = before_body + clean_script(class_function, built_args).html_safe + after_body
        end
      end
    end

    def clean_script(class_function, args)
      "<script type='application/javascript'>jQuery(document).ready(function($) {" + render_to_string(js: class_function + args) + "});</script>"
    end

    def hash_to_js_args(args)
      js_args = []

      args.each_pair do |k, v|
        js_args << (k.to_s + ": " + v.to_s)
      end
      js_args
    end

  end
end

module YourGemsModuleName
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
    def js(js_class: nil, method: nil, partial: nil)
        return unless [:js, :html].include?(request.format.to_sym)

        js_class ||= self.class.name.gsub("::", ".")
        method ||= action_name

        if partial.present?
          appendable = (render_to_string partial: partial).gsub("\n", "")
          arg = "('#{appendable}');"
        else
          arg = "()"
        end

        class_method = [js_class, method].join(".")
        if request.format.to_sym == :js
          render js: class_method + arg
        elsif request.format.to_sym == :html
          render
          response_body = response.body
          before_body_end_index = response_body.rindex('</body>')

          if before_body_end_index.present?
            before_body = response_body[0, before_body_end_index].html_safe
            after_body = response_body[before_body_end_index..-1].html_safe

            response.body = before_body + clean_script(class_method, arg).html_safe + after_body
          end
        end
      end
    end

    def clean_script(class_method, arg)
      "<script type='application/javascript'>jQuery(document).ready(function($) {" + render_to_string(js: class_method + arg) + "});</script>"
    end

  end
end

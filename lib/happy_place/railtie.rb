module HappyPlace
  class Railtie < Rails::Railtie
    initializer "your_gem_name.action_controller" do
    ActiveSupport.on_load(:action_controller) do
      puts "Extending #{self} with YourGemsModuleName::Controller"
      # ActionController::Base gets a method that allows controllers to include the new behavior
      include HappyPlace::Controller # ActiveSupport::Concern
    end
  end
end

if Rails.env.development?
  # TODO auto generate
  # https://github.com/rails/rails/blob/master/actionpack/lib/action_controller/log_subscriber.rb
  module ActionController
    class LogSubscriber < ActiveSupport::LogSubscriber
      def start_processing(event)
        return unless logger.info?

        payload = event.payload
        params  = payload[:params].except(*INTERNAL_PARAMS)
        format  = payload[:format]
        format  = format.to_s.upcase if format.is_a?(Symbol)

        info "Processing by #{payload[:controller]}##{payload[:action]} as #{format}"
        #info "  Parameters: #{params.inspect}" unless params.empty?
        info "  Parameters: #{ap params}" unless params.empty?
      end
    end
  end
end

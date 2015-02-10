module ReceiptBank
  module Models
    class BaseModel
      BASE_URI = '/api/'

      VALID_RESOURCE_ACTIONS = [:get, :delete, :add]

      attr_accessor :client_connection

      def initialize(client, options = {}, loaded_from_server = false)
        @client_connection = client
        @attributes = {}
        set_all_attributes(options, loaded_from_server)
      end

      def self.resource_name
        name.split('::').last.downcase + 's'
      end

      def self.build_url(resource_action)
        "#{BASE_URI}#{(resource_action == :get ? '' : resource_action.to_s + '_')}#{resource_name}"
      end

      def self.find(user, params = {})
        client_connection = user.client_connection
        params.merge!(sessionid: user.session[:session_id])
        process_results(client_connection,
                        client_connection.query_post_api(build_url(:get), params))
      end

      def self.process_results(client_connection, results, result_field_name = resource_name)
        results[result_field_name].inject([]) do |arr, data_item|
          arr << new(client_connection, data_item, true)
        end
      end

      def session
        client_connection.current_user.session
      end

      def delete
        return false unless id
        options = { self.class.resource_name => [{ id: id }],
                    :sessionid => session[:session_id] }
        response = client_connection.query_post_api(self.class.build_url(:delete), options)
        response['size'] == 0
      end

      def save
        return self unless is_dirty?
        options = { self.class.resource_name => [build_changed_data] }.merge(build_session_data)
        response = client_connection.query_post_api(self.class.build_url(:add), options)
        set_all_attributes(response[self.class.resource_name].first, true) if response['size'] > 0
        self
      end

      def reload
        response = self.class.find(client_connection, id: id)
        return false if response['size'] ==  0
        remote_data = response[self.class.resource_name].select { |model_instance| model_instance.id == id }.first
        set_all_attributes(remote_data, true)
        true
      end

      def is_dirty?
        get_dirty_attributes.size > 0
      end

      def method_missing(method, *args, &block)
        attribute_name = method.to_s.split('=')
        if has_attribute?(attribute_name.first)
          if method.to_s[-1] == '='
            set_attribute(attribute_name.first, args.first)
          else
            get_attribute(attribute_name.first)
          end
        else
          super
        end
      end

      def build_session_data
        { sessionid: session[:session_id] }
      end

      def build_changed_data
        get_dirty_attributes.keys.inject({}) do |h, k|
          if @attributes[k][:value] && k != 'id' && !@attributes[k][:value].to_s.empty?
            h[k] = @attributes[k][:value]
          end
          h
        end
      end

      def has_attribute?(key)
        @attributes && @attributes.key?(key.gsub(/=/, ''))
      end

      def get_dirty_attributes
        @attributes ? @attributes.select { |_k, v| v[:is_dirty] } : []
      end

      def clear_dirty_flags
        @attributes.each do |k, v|
          @attributes[k] = { old_value: v[:value], value: v[:value], is_dirty: false }
        end
      end

      def get_attribute(key)
        has_attribute?(key) ? @attributes[key][:value] : nil
      end

      def set_all_attributes(attributes, loaded = false)
        attributes.each do |k, v|
          if self.respond_to? k
            send("#{k}=", v)
          else
            set_attribute(k.to_s, v, loaded)
          end
        end
      end

      def set_attribute(key, value, loaded = false)
        @attributes[key] = { old_value: get_attribute(key) || value,
                             value: value,
                             is_dirty: !loaded || get_attribute(key) == value }
        true
      end
    end
  end
end

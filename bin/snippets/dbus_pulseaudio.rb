require 'dbus'

class DBus::Pulseaudio

    attr_accessor :socket_path, :connection

    OBJECTS = {
        :core => ['org.PulseAudio.Core1','/org/pulseaudio/core1']
    }

    def socket_path
      @socket_path ||= get_socket_path
    end

    def connection
      @connection ||= get_connection
    end

    def get_socket_path
      session_bus = DBus.session_bus
      pulseaudio_service = session_bus.service 'org.PulseAudio1'
      pulseaudio = pulseaudio_service.object '/org/pulseaudio/server_lookup1'
      pulseaudio.introspect
      server_lookup = pulseaudio['org.PulseAudio.ServerLookup1']
      address = server_lookup['Address']
      address.split('=').last
    end

    def get_connection
      connection = DBus::Connection.new("unix:path=#{socket_path}")
      connection.connect
      connection
    end

    alias :bus :connection

    def object(interface, path)
      service = connection.service(interface)
      object = service.object(path)
      object.default_iface = interface
      object.introspect
      object
    end

    def interface(interface, path)
      object(interface,path)[interface]
    end

    #def method_missing
    # retrieve and cache objects
    #end

    def core
      object('org.PulseAudio.Core1','/org/pulseaudio/core1')
    end

    def get_sources
      core['Sources']
    end
end
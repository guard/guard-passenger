require 'guard'
require 'guard/guard'
require 'rubygems'

module Guard
  class Passenger < Guard

    autoload :Runner, 'guard/passenger/runner'
    autoload :Pinger, 'guard/passenger/pinger'

    attr_reader :cli_start, :cli_stop, :ping, :notification, :sudo

    def standalone?
      @standalone
    end

    # =================
    # = Guard methods =
    # =================

    def initialize(watchers = [], options = {})
      super

      warn_deprectation options
      @standalone   = options[:standalone].nil? ? true : options[:standalone]
      @cli_start    = init_cli(options)
      @cli_stop     = cli_stop
      @notification = options[:notification].nil? ? true : options[:notification]

      ping_opt = unless options[:touch].nil?
        UI.info "Warning: The :touch option has been replaced by the :ping option, usage is still the same."
        options[:touch]
      else
        options[:ping]
      end
      @ping = ping_opt.eql?(true) ? '/' : ping_opt

      @sudo = options[:sudo] || ''
      @sudo = @sudo.eql?(true) ? 'sudo' : @sudo
    end

    # Call once when guard starts
    def start
      UI.info 'Guard::Passenger is running!'
      standalone? ? Runner.start_passenger(cli_start, @sudo) : true
    end

    # Call with Ctrl-C signal (when Guard quit)
    def stop
      UI.info 'Stopping Passenger...'
      Runner.stop_passenger(cli_stop, @sudo) if standalone?
      true
    end

    # Call with Ctrl-Z signal
    def reload
      restart_and_ping
    end

    # Call on file(s) modifications
    def run_on_change(paths = {})
      restart_and_ping
    end

    private

      def init_cli options={}
        cmd_parts = []
        cmd_parts << (options[:cli].nil? ? '--daemonize' : options[:cli])
        cmd_parts << "--port #{options[:port]}" if options[:port] #DEPRICATED
        cmd_parts << "--environment #{options[:env]}" if options[:env] #DEPRICATED
        cmd_parts.join(' ')
      end

      def cli_stop
        cmd_parts = []
        cmd_parts << "--port #{port}" if port != 3000
        cmd_parts << "--pid_file #{pid_file}" if pid_file
        cmd_parts.join(' ')
      end

      def port
        if cli_start =~ /(?:-p|--port)/
          cli_start.match(/(?:-p|--port) ([^ ]+)/)[1]
        else
          '3000'
        end
      end

      def address
        if cli_start =~ /(?:-a|--address)/
          cli_start.match(/(?:-a|--address) ([^ ]+)/)[1]
        else
          '0.0.0.0'
        end
      end

      def pid_file
        if cli_start =~ /(--pid-file)/
          cli_start.match(/--pid-file ([^ ]+)/)[1]
        else
          nil
        end
      end

      def restart_and_ping
        UI.info 'Restarting Passenger...'
        restarted = Runner.restart_passenger
        Pinger.ping(address, port, notification, ping) if ping
        restarted
      end

      def warn_deprectation(options={})
        options[:environment] = options[:env] if options[:env]
        [:port, :environment].each do |option|
          key, value = [option, option.to_s.gsub('_', '-')]
          if options.key?(key)
            UI.info "DEPRECATION WARNING: The :#{key} option is deprecated. Pass standard command line argument \"--#{value}\" to Passenger with the :cli option."
          end
        end
      end

  end
end

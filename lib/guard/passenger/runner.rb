module Guard
  class Passenger
    module Runner
      class << self

        def restart_passenger
          succeed = system("touch tmp/restart.txt")
          if succeed
            UI.info "Passenger successfully restarted."
          else
            UI.error "Passenger failed to restart!"
          end
          succeed
        end

        def start_passenger(cli, sudo = '')
          if passenger_standalone_installed?
            succeed = system("#{sudo} passenger start #{cli}".strip)
            if succeed
              UI.info "Passenger standalone started."
            else
              UI.error "Passenger standalone failed to start!"
            end
            succeed
          else
            UI.error "Passenger standalone is not installed. You need at least Passenger version >= 3.0.0.\nPlease run 'gem install passenger' or add it to your Gemfile."
            false
          end
        end

        def stop_passenger(cli, sudo = '')
          succeed = system("#{sudo} passenger stop #{cli}".strip)
          if succeed
            UI.info "Passenger standalone stopped."
          else
            UI.error "Passenger standalone failed to stop!"
          end
          succeed
        end

        def passenger_standalone_installed?
          begin
            gem "passenger", ">=3.0.0"
          rescue Gem::LoadError
            return false
          end
          true
        end

      end
    end
  end
end

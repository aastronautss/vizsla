require 'tracebin/helpers'

module Tracebin
  class Event
    include Tracebin::Helpers

    attr_reader :event

    def initialize(event)
      @event = event
    end

    def recorder_type
      event[0]
    end

    def valid?
      true
    end

    def data_hash
      {
        event_type: type,
        start: event[1],
        stop: event[2],
        duration: to_milliseconds(event[2] - event[1]),
        data: select_data || event.last
      }
    end
  end

  class SQLEvent < Event
    def valid?
      event.last[:name] != "SCHEMA"
    end

    private

    def type
      :sql
    end

    def select_data
      {
        sql: event.last[:sql],
        name: event.last[:name],
        statement_name: event.last[:statement_name]
      }
    end
  end

  class ControllerEvent < Event
    private

    def type
      :controller_action
    end

    def select_data
      {
        controller: event.last[:controller],
        action: event.last[:action],
        format: event.last[:format],
        method: event.last[:method],
        path: event.last[:path],
        status: event.last[:status],
        view_runtime: event.last[:view_runtime],
        db_runtime: event.last[:db_runtime]
      }
    end
  end

  class ViewEvent < Event
    private

    def type
      :view
    end

    def select_data
      nil
    end
  end

  class SinatraEvent < Event
    private

    def type
      :route
    end

    def select_data
      nil
    end
  end
end

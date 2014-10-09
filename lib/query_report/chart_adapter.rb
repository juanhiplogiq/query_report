# Author::    A.K.M. Ashrafuzzaman  (mailto:ashrafuzzaman.g2@gmail.com)
# License::   MIT-LICENSE

# The purpose of the filter module is adapt the chart features form chartify
require 'chartify/factory'

module QueryReport
  module ChartAdapterModule
    attr_reader :charts

    def initialize_charts
      @charts = []
    end

    def chart(chart_type, chart_title, &block)
      chart_adapter = ChartAdapter.new(filtered_query, records_without_pagination, chart_type, chart_title)
      block.call(chart_adapter)
      @charts << chart_adapter.chart
    end

    class ChartAdapter
      attr_reader :query, :records
      attr_accessor :chart_type, :chart
      delegate :data, :data=, :columns, :columns=, :label_column, :label_column=, to: :chart

      def initialize(query, records, chart_type, chart_title)
        @query = query
        @records = records
        @chart_type = chart_type
        @chart = "Chartify::#{chart_type.to_s.camelize}Chart".constantize.new
        @chart.title = chart_title
      end

      def sum_with(options)
        @chart.data = []
        options.each do |column_title, column|
          @chart.data << [column_title, query.sum(column)]
        end
      end

      def count_with(options)
        @chart.data = []
        counts   = query.group(options.fetch(:column)).count
        title_mappings = options.fetch(:title_mappings){nil}

        counts.each do |column_value, column_count|
          title = title_mappings ? title_mappings.fetch(column_value){column_value.to_s} : column_value.to_s
          @chart.data << [title, column_count]  
        end
      end
    end
  end
end
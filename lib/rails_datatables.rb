module RailsDatatables
  def datatable(columns, opts={})
    sort_by = opts[:sort_by] || nil
    additional_data = opts[:additional_data] || {}
    search = opts[:search].present? ? opts[:search].to_s : "true"
    search_label = opts[:search_label] || "Search"
    processing = opts[:processing] || "Processing"
    persist_state = opts[:persist_state].present? ? opts[:persist_state].to_s : "true"
    table_dom_id = opts[:table_dom_id] ? "##{opts[:table_dom_id]}" : ".datatable"
    per_page = opts[:per_page] || opts[:display_length]|| 25
    no_records_message = opts[:no_records_message] || nil
    auto_width = opts[:auto_width].present? ? opts[:auto_width].to_s : "true"
    row_callback = opts[:row_callback] || nil

    append = opts[:append] || nil

    ajax_source = opts[:ajax_source] || nil
    server_side = opts[:ajax_source].present?

    additional_data_string = ""
    additional_data.each_pair do |name,value|
      additional_data_string = additional_data_string + ", " if !additional_data_string.blank? && value
      additional_data_string = additional_data_string + "{'name': '#{name}', 'value':'#{value}'}" if value
    end

    %Q{
    <script type="text/javascript">
    $(function() {
        $('#{table_dom_id}').dataTable({
          "oLanguage": {
            "sSearch": "#{search_label}",
            #{"'sZeroRecords': '#{no_records_message}'," if no_records_message}
            "sProcessing": '#{processing}'
          },
          "sPaginationType": "full_numbers",
          "iDisplayLength": #{per_page},
          "bProcessing": true,
          "bServerSide": #{server_side},
          "bLengthChange": false,
          "bStateSave": #{persist_state},
          "bFilter": #{search},
          "bAutoWidth": #{auto_width},
          #{"'aaSorting': [#{sort_by}]," if sort_by}
          #{"'sAjaxSource': '#{ajax_source}'," if ajax_source}
          "aoColumns": [
      			#{formatted_columns(columns)}
      				],
      		#{"'fnRowCallback': function( nRow, aData, iDisplayIndex ) { #{row_callback} }," if row_callback}
          "fnServerData": function ( sSource, aoData, fnCallback ) {
            aoData.push( #{additional_data_string} );
            $.getJSON( sSource, aoData, function (json) {
      				fnCallback(json);
      			} );
          }
        })#{append};
    });
    </script>
    }
  end

  private
    def formatted_columns(columns)
      i = 0
      columns.map {|c|
        i += 1
        if c.nil? or c.empty?
          "null"
        else
          searchable = c[:searchable].to_s.present? ? c[:searchable].to_s : "true"
          sortable = c[:sortable].to_s.present? ? c[:sortable].to_s : "true"

          "{
          'sType': '#{c[:type] || "string"}',
          'bSortable':#{sortable},
          'bSearchable':#{searchable}
          #{",'sClass':'#{c[:class]}'" if c[:class]}
          }"
        end
      }.join(",")
    end
end
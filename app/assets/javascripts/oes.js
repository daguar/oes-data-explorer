// All JS specific to this app lives here
// Below is only used on the front page

jQuery(function($)
{
  $("#area_state").change(function()
    {
        var state = $('select#area_state :selected').val();
        if(state == "") {
          $("#msas select").empty()
        }
        else 
          jQuery.get(
            '/getmsas/' + state,
            function(data){ $("#msas").html(data); },
            "html"
          )
      return false;
    }
  );
  $('#jobs_job_title').bind('railsAutocomplete.select', function(event, data)
    {
      $('form').submit();
      $("body").addClass("loading"); 
    }
  );
})


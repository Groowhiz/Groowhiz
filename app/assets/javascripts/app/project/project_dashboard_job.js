App.addChild('DashboardJobs', {
  el: '#dashboard-jobs-tab',

  events:{
    "cocoon:after-insert #jobs": "reloadSubViews"
  },

  activate: function() {
    this.$jobs = this.$('#dashboard-jobs #jobs');
    this.sortableJobs();
  },

  reloadSubViews: function(event, insertedItem) {
    this.jobForm.undelegateEvents();
    this._jobForm = null;
    this.jobForm;
  },

  sortableJobs: function() {
    that = this;
    this.$jobs.sortable({
      axis: 'y',
      placeholder: "ui-state-highlight",
      start: function(e, ui) {
        return ui.placeholder.height(ui.item.height());
      },
      update: function(e, ui) {
        var csrfToken, position;
        position = that.$('#dashboard-jobs .nested-fields').index(ui.item);
        csrfToken = $("meta[name='csrf-token']").attr("content");
        update_url = that.$(ui.item).find('.card-persisted').data('update_url');
        return $.ajax({
          type: 'POST',
          url: update_url,
          dataType: 'json',
          headers: {
            'X-CSRF-Token': csrfToken
          },
          data: {
            job: {
              row_order_position: position
            }
          }
        });
      }
    });
  }
});

App.views.DashboardJobs.addChild('JobForm', _.extend({
  el: '.job-card',

  events: {
    'blur input' : 'checkInput',
    'blur textarea' : 'checkInput',
    'submit form' : 'validate',
    "click #limit_job": "showInput",
    "click .job-close-button": "closeForm",
    "click .fa-question-circle": "toggleExplanation",
    "click .show_job_form": "showJobForm"
  },

  activate: function(){
    this.setupForm();
  },

  showInput: function(event) {
    var $target = this.$(event.currentTarget);
    var $max_field = $target.parent().parent().parent().next('.job_maximum_contributions');
    var $input = $('input', $max_field);

    $max_field.toggle();

    if(!$max_field.is(':visible')) {
      $input.val('');
    }
  },

  toggleExplanation: function(event) {
    event.preventDefault();
    var $target = this.$(event.currentTarget);
    $target.parent().next('.job-explanation').toggle();
  },

  closeForm: function(event) {
    event.preventDefault();
    var $target = this.$(event.currentTarget);
    $target.closest('.card-edition').hide();
    $target.closest('.card-edition').parent().find('.card-persisted').show();
  },

  showJobForm: function(event) {
    event.preventDefault();
    var $target = this.$(event.currentTarget);
    this.$($target.data('parent')).hide();
    this.$($target.data('target')).show();
  }

}, Skull.Form));

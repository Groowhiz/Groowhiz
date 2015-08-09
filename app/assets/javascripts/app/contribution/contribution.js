App.addChild('Contribution', {
  el: '#new-contribution',

  events: {
    'click .radio label' : 'clickReward',
    'click .submit-form' : 'submitForm',
    'click .user-reward-value' : 'clearOnFocus',
    'input #contribution_value' : 'restrictChars'
  },

  restrictChars: function(event){
    var $target = $(event.target);
    $target.val($target.val().replace(/[^\d,]/, ''));
  },

  submitForm: function(event){
    var $target_row = $(event.target).parents('.back-reward-money'),
        user_value = this.$('.selected').find('.user-reward-value').val().replace(/\./g,'');
    this.$value.val(user_value);
    if(parseInt(user_value) < parseInt(this.minimumValue())){
      $target_row.find('.user-reward-value').addClass('error');
      $target_row.find('.text-error').slideDown();
    }else{
      this.$('form').submit();  
    }

    return false;
  },

  activate: function(){
    this.$('.user-reward-value').mask('000.000.000,00', {reverse: true});
    this.$value = this.$('#contribution_value');
    this.$minimum = this.$('#minimum-value');
    this.clickReward({currentTarget: this.$('input[type=radio]:checked').parent()}); 
    this.isOnAutoScroll = false;
    this.activateFloattingHeader();
  },

  activateFloattingHeader: function(){
    var that = this,
        top,
        top_title = $('#new-contribution'),
        faq_top = $("#faq-box").offset().top;
    $(window).scroll(function() {
        if(!that.isOnAutoScroll && !app.isMobile()){
            top = $(top_title).offset().top,
            $(window).scrollTop() > top ? $(".reward-floating").addClass("reward-floating-display") : $(".reward-floating").removeClass("reward-floating-display");
            var t = $("#faq-box");
            $(window).scrollTop() > faq_top-130 ? $(t).hasClass("faq-card-fixed") || $(t).addClass("faq-card-fixed") : $(t).hasClass("faq-card-fixed") && $(t).removeClass("faq-card-fixed");
        }       
    });
  },

  clearOnFocus: function(event){ 
    this.$(event.target).val("");
    this.$('.error').removeClass('error');
    this.$('.text-error').slideUp();
    return false;
  },
  
  customValidation: function(event){
    if(parseInt(this.$value.val()) < this.minimumValue()){
      this.selectReward(this.$('.radio label'));
    }
  },

  minimumValue: function(){
    return this.$('.selected').find('label[data-minimum-value]').data('minimum-value');
  },

  resetSelected: function(){
    this.$('.w-radio').removeClass('selected');
  },

  selectReward: function(reward){
    this.resetSelected();
    reward.find('input[type=radio]').prop('checked', true);
    this.$('.back-reward-money').hide();
    reward.find('.back-reward-money').show();
    reward.parent().addClass('selected');
  },

  clickReward: function(event){
    var $el = $(event.currentTarget);
    var isOnAutoScroll = this.isOnAutoScroll;
    $.smoothScroll({
      scrollTarget: $el,
      speed: 600,
      offset: -250,
      callback: function(){
        isOnAutoScroll = false;
      }
    });
    this.selectReward($el);
    var minimum = this.minimumValue();
    $el.find('.user-reward-value').val(minimum);
  }
});

App.addChild('FaqBox', {
  el: '#faq-box',

  events: {
    'click li.list-question' : 'clickQuestion'
  },

  clickQuestion: function(event){
    var $question = $(event.currentTarget);
    var $answer = $question.next();
    $question.toggleClass('open').toggleClass('alt-link');
    $answer.slideToggle('slow');
  },

  activate: function(){
    this.$('li.list-answer').hide();
  }
});

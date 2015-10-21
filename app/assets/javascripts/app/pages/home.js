App.addChild('Home', {
  el: '#hero-home',

  activate: function(){
    $.animateHeadline();
  },

});

App.addChild('HomeNewsletter', {
  el: '#mailee-form',

  events: {
	'click a.btn-attached':'submitForm',
  },

  submitForm: function(event){
	  event.preventDefault();
	  this.$el.submit();
  },

});

App.addChild('Home',{
    el: '#home-slider',
    load: function(){
        $('.main-slider').addClass('animate-in');
        $('.preloader').remove();
    }
})

// portfolio filter
//$(window).load(function() {

   // $('.main-slider').addClass('animate-in');
   // $('.preloader').remove();
//});
//End Preloader
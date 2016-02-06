App.addChild('ExploreTalents', _.extend({
    el: 'body[data-action="show"][data-controller-name="pages"][data-id="explore_talents"]',

    events: {
        'click .explore-talents-toggle':'toggleCategoryList',
        'click .explore-talents-link' : 'toggleCategoryList',
        'click #load-more' : 'loadMore'
    },

    routeFilters: {
        recent: { recent: true },
        recommended: { recommended: true },
        successful: { successful: true },
        singing : {singing: true},
        song_writing: {song_writing: true},
        instrumental: {instrumental: true},
        music_composition: {music_composition: true},
        music_teaching: {music_teaching: true},
        music_production: {music_production: true},
        music_technology: {music_technology: true},
        music_management: {music_management: true},
        band: {band: true}

    },

    activate: function(){

        this.route('recommended');
        this.route('recent');
        this.route('singing');
        this.route('song_writing');
        this.route('instrumental');
        this.route('music_composition');
        this.route('music_teaching');
        this.route('music_production');
        this.route('music_technology');
        this.route('music_management');
        this.route('band');
        this.route('successful');
        this.route('by_category_id/:id');
        this.route('near_of/:state');
        this.route('by_genre_id/:id');

        this.setInitialFilter();

        this.setupPagination(
            this.$("#loading img"),
            this.$('#load-more'),
            this.$(".results"),
            this.$("#explore_talents_results").data('talents-path')
        );

        if(window.location.hash === ''){
            var search_string = window.location.search.indexOf("pg_search");
            this.fetchPage();

            if(search_string == -1){
                this.toggleCategoryList();
            }
        }
    },

    toggleCategoryList: function(event) {
        this.$('#categories-wrapper').slideToggle();
        $.smoothScroll({
            scrollElement: $('html, body')
        });
    },

    selectLink: function(){
        this.$('.follow-category').hide();

        var link = this.$('a[href="' + window.location.hash + '"]');
        this.$('a.selected').removeClass('selected');

        link.addClass('selected');

        if(link.data('categoryid') || link.data('name')) {
            this.followCategory.setupFollowHeader(link);
        }
    },

    followRoute: function(route, name, params){
        this.filter = {page: 1};

        if(params.length > 0 && _.isString(params[0])){
            this.filter[name] = params[0];
        }
        else{
            this.filter[name] = true;
        }

        this.$('.results').empty();

        this.fetchPage();

        if(this.parent && this.parent.$search.length > 0){
            this.parent.$search.val('');
        }
        this.selectLink();
    },

    setInitialFilter: function(){
        var search = null;
        if(this.parent && (search = this.parent.$search.val())){
            this.filter = { pg_search: search };
        }
        else{
            this.filter = {
                recommended: true
            };
        }
    },

}, Skull.Pagination));

App.views.ExploreTalents.addChild('FollowCategory', {
    el: '.follow-category',

    setupFollowHeader: function(selectedItem) {
        var unfollow_btn = this.$('.unfollow-btn');
        var follow_btn = this.$('.follow-btn');

        this.$('.btn.btn-medium').hide();
        this.$('.category-info').html(selectedItem.data('name'));
        this.$('.following').hide();

        if(selectedItem.data('categoryid') > 0) {
            this.$('.category-follow span.count').html(selectedItem.data('totalfollowers'));

            if(selectedItem.data('totalfollowers') > 0) {
                this.$('.following').show();
            }

            if(selectedItem.data('isfollowing')) {
                unfollow_btn.prop('href', selectedItem.data('unfollowpath'));
                unfollow_btn.show();
            } else {
                follow_btn.prop('href', selectedItem.data('followpath'));
                follow_btn.show();
            }
        }

        this.$el.show();
    }

});

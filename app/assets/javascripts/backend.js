//= require jquery
//= require jquery_ujs
//= require bootstrap-sprockets
//= require bootbox
//= require backend/functions.js
//= require bootstrap-wysihtml5
//= require bootstrap-wysihtml5/locales/fr-FR


$(document).on("ready",function(){
	$('.html-editor').wysihtml5({
		'toolbar': {'html': true,'fa': true}
	});
})

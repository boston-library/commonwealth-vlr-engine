/* prevent the Bootstrap-collapse-triggering volume title links from going to the link target */
/* this allows links to still be clickable for users w/o JS */
$('#volumes_wrapper').find('a.volume_title').on("click", function (e) {
    e.preventDefault();
});
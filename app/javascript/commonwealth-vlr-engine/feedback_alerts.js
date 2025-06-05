/* replaces help text, depending on value selected from 'message type' drop-down */
const feedbackAlerts = (e) => {
    const topic_dropdown_selector = '#message_type_select';
    if (e.target.matches(topic_dropdown_selector)) {
        const topic_dropdown = document.querySelector(topic_dropdown_selector);
        const help_text_div = document.querySelector('#contact_help_text');

        const dataset = topic_dropdown.dataset || {};
        const raw_options = dataset.topicOptions;

        if(!raw_options) return;

        const topic_options = JSON.parse(raw_options);
        const topic_options_keys = Object.keys(topic_options);

        const selected_option = topic_dropdown.value;

        for (let i = 0; i < topic_options_keys.length; i++) {
            const entry = topic_options[topic_options_keys[i]];
            if (selected_option === entry.option) {
                if (entry.help_text !== '') {
                    help_text_div.innerHTML = entry.help_text;
                    help_text_div.style.display = "block";
                } else {
                    help_text_div.style.display = "none";
                }
            }
        }
    }
}

document.addEventListener("change", feedbackAlerts);

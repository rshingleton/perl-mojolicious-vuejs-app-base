package MojoVue::Controller::Vue;
use Mojo::Base 'Mojolicious::Controller', -signatures;


sub index($self) {
    # Serves up index.html from the public directory
    $self->reply->static('index.html');
}

# This action will render a template
sub hello($self) {
    # Render template "example/welcome.html.ep" with message
    $self->render(msg => 'Welcome to the Mojolicious real-time web framework with Vue.js!');
}

1;

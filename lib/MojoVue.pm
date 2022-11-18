package MojoVue;
use Mojo::Base 'Mojolicious', -signatures;

# This method will run once at server start
sub startup ($self) {

  # Load configuration from config file
  my $config = $self->plugin('NotYAMLConfig');

  # Configure the application
  $self->secrets($config->{secrets});

  # Router
  my $r = $self->routes;

  # Normal route to controller
  $r->get('/')->to('Vue#index');

  #-------------------------------------------------------------
  # Any other named routes to be handled outside the vue router
  #-------------------------------------------------------------
  
  # Mojo example route
  $r->get('/example')->to('Example#welcome');
  
  # Vue SPA example route
  $r->get('/hello')->to('Vue#hello');
  
  #-------------------------------------------------------------
  
  
  # handle vue router, routes anything that does not match previous
  # definitions to vue. 404 should be handled in the vue router
  $r->any('/*')->to('Vue#index');

}

1;

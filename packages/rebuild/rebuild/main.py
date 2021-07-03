import socket
import getpass

import click
from click import group, command, option

@group()
@option('-h', '--host', 'host', default=lambda: socket.gethostname(), type=str, help="Hostname to build for")
@option('-u', '--user', 'user', default=lambda: getpass.getuser(), type=str, help="Username to build for")
def main(host, user):
    pass

@main.command()
def build(host, user):
    """Build the system and user configurations"""
    click.echo("{}@{}".format(user, host))
    pass

@main.command()
def switch():
    """Switches  system and user  configuration"""
    pass

if __name__ == '__main__':
    main()

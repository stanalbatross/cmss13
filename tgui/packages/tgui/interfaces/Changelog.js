import { classes } from 'common/react';
import { useBackend } from '../backend';
import { Component, Fragment } from 'inferno';
import {
  Box,
  Button,
  Dropdown,
  Icon,
  Section,
  Stack,
  Table,
} from '../components';
import { Window } from '../layouts';
import { resolveAsset } from '../assets';
import dateformat from 'dateformat';
import yaml from 'js-yaml';

const icons = {
  bugfix: { icon: 'bug', color: 'green' },
  wip: { icon: 'hammer', color: 'orange' },
  qol: { icon: 'hand-holding-heart', color: 'green' },
  soundadd: { icon: 'tg-sound-plus', color: 'green' },
  sounddel: { icon: 'tg-sound-minus', color: 'red' },
  add: { icon: 'check-circle', color: 'green' },
  expansion: { icon: 'check-circle', color: 'green' },
  rscadd: { icon: 'check-circle', color: 'green' },
  rscdel: { icon: 'times-circle', color: 'red' },
  imageadd: { icon: 'tg-image-plus', color: 'green' },
  imagedel: { icon: 'tg-image-minus', color: 'red' },
  spellcheck: { icon: 'spell-check', color: 'green' },
  experiment: { icon: 'radiation', color: 'yellow' },
  balance: { icon: 'balance-scale-right', color: 'yellow' },
  code_imp: { icon: 'code', color: 'green' },
  refactor: { icon: 'tools', color: 'green' },
  config: { icon: 'cogs', color: 'purple' },
  admin: { icon: 'user-shield', color: 'purple' },
  server: { icon: 'server', color: 'purple' },
  tweak: { icon: 'wrench', color: 'green' },
  unknown: { icon: 'info-circle', color: 'label' },
};

export class Changelog extends Component {
  constructor() {
    super();
    this.state = {
      data: 'Loading changelog data...',
      selectedDate: '',
      selectedIndex: 0,
    };
  }

  setData(data) {
    this.setState({ data });
  }

  setSelectedIndex(selectedIndex) {
    this.setState({ selectedIndex });
  }
  render() {
    const { data, selectedIndex } = this.state;
    const { data: { raw_changelog } } = useBackend(this.context);

    const header = (
      <Section>
        <h1>Colonial Marines - Space Station 13</h1>
        <p>
          <b>Thanks to: </b>
          Baystation 12, /tg/station, /vg/station, NTstation, CDK Station devs,
          FacepunchStation, GoonStation devs, the original Space Station 13
          developers, Invisty for the title image and the countless others who
          have contributed to the game, issue tracker or wiki over the years.
        </p>
      </Section>
    );

    const changes = typeof data === 'object' && Object.keys(data).length > 0 && (
      Object.entries(data).reverse().map(([date, authors]) => (
        <Section key={date} title={dateformat(date, 'd mmmm yyyy', true)}>
          <Box ml={3}>
            {Object.entries(authors).map(([name, changes]) => (
              <Fragment key={name}>
                <h4>{name} changed:</h4>
                <Box ml={3}>
                  <Table>
                    {changes.map(change => {
                      const changeType = Object.keys(change)[0];
                      return (
                        <Table.Row key={changeType + change[changeType]}>
                          <Table.Cell
                            className={classes([
                              'Changelog__Cell',
                              'Changelog__Cell--Icon',
                            ])}
                          >
                            <Icon
                              color={
                                icons[changeType]
                                  ? icons[changeType].color
                                  : icons['unknown'].color
                              }
                              name={
                                icons[changeType]
                                  ? icons[changeType].icon
                                  : icons['unknown'].icon
                              }
                            />
                          </Table.Cell>
                          <Table.Cell className="Changelog__Cell">
                            {change[changeType]}
                          </Table.Cell>
                        </Table.Row>
                      );
                    })}
                  </Table>
                </Box>
              </Fragment>
            ))}
          </Box>
        </Section>
      ))
    );

    return (
      <Window title="Changelog" width={675} height={650}>
        <Window.Content scrollable>
          {header}
          {changes}
          {typeof data === 'string' && <p>{data}</p>}
        </Window.Content>
      </Window>
    );
  }
}

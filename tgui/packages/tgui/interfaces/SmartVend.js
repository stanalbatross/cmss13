import { useBackend } from '../backend';
import { Button, Section, Table, NoticeBox } from '../components';
import { map } from 'common/collections';
import { Window } from '../layouts';

export const SmartVend = (props, context) => {
  const { act, data } = useBackend(context);
  const transferring = data.transfer_mode;

  return (
    <Window
      width={440}
      height={550}
    >
      <Window.Content scrollable>
        {!!data.secure && (
          <NoticeBox>
            Secure access : pleaseg have your ID or dogtags ready.
          </NoticeBox>
        )}
        {!!data.transfer_mode && (
          <Button
            fluid={1}
            icon="sliders-h"
            title="Toggle transfer mode"
            content="Mode : dispense"
            onClick={() => act('toggletransfer')} />
        ) || (
          <Button
            fluid={1}
            icon="sliders-h"
            title="Toggle transfer mode"
            content="Mode : dispense"
            onClick={() => act('toggletransfer')} />
        )}
        <Section title="Storage" >
          {data.contents.length === 0 ? (
            <NoticeBox>
              Unfortunately, this {data.proper_name} is empty.
            </NoticeBox>
          ) : (
            <Table>
              <Table.Row>
                <Table.Cell>Item</Table.Cell>
                <Table.Cell>Quantity</Table.Cell>
                <Table.Cell>{transferring ? "Transfer" : "Dispense"}</Table.Cell>
              </Table.Row>
              {map((value, key) => {
                return (
                  <Table.Row key={key}>
                    <Table.Cell>{value.name}</Table.Cell>
                    <Table.Cell>{value.amount}</Table.Cell>
                    <Table.Cell>
                      <Button
                        disabled={value.amount < 1}
                        onClick={() => act(
                          'Release',
                          { name: value.name, amount: 1, from_network: 0 })}>
                        One
                      </Button>
                      <Button
                        disabled={value.amount <= 1}
                        onClick={() => act(
                          'Release',
                          { name: value.name, from_network: 0 })}>
                        Many
                      </Button>
                    </Table.Cell>
                  </Table.Row>
                );
              })}
            </Table>
          )}
        </Section>
        {!!data.networked && (
          <Section title="Networked storage" >
            {data.networked_contents.length === 0 ? (
              <NoticeBox>
                Unfortunately, this networked storage is empty.
              </NoticeBox>
            ) : (
              <Table>
                <Table.Row>
                  <Table.Cell>Item</Table.Cell>
                  <Table.Cell>Quantity</Table.Cell>
                  <Table.Cell>Transfer</Table.Cell>
                </Table.Row>
                {map((value, key) => {
                  return (
                    <Table.Row key={key}>
                      <Table.Cell>{value.name}</Table.Cell>
                      <Table.Cell>{value.amount}</Table.Cell>
                      <Table.Cell>
                        <Button
                          disabled={value.amount < 1}
                          onClick={() => act(
                            'Release',
                            { name: value.name, amount: 1, from_network: 1 })}
                        >
                          One
                        </Button>
                        <Button
                          disabled={value.amount <= 1}
                          onClick={() => act(
                            'Release',
                            { name: value.name, from_network: 1 })}>
                          Many
                        </Button>
                      </Table.Cell>
                    </Table.Row>
                  );
                })}
              </Table>
            )}
          </Section>
        )}
      </Window.Content>
    </Window>
  );
};

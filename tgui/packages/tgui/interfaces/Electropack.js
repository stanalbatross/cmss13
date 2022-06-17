import { useBackend } from '../backend';
import { Button, Section, Knob, LabeledList } from '../components';
import { Window } from '../layouts';

export const Electropack = (props, context) => {
  const { act, data } = useBackend(context);
  const { max_freq, min_freq, max_signal, min_signal } = data;

  return (
    <Window
      width={160}
      height={170}
    >
      <Window.Content>
        <Section>
          <LabeledList>
            <LabeledList.Item label="Frequency">
              <Knob
                inline
                maxValue={max_freq}
                minValue={min_freq}
                value={data.current_freq}
                onChange={(e, value) => act("set_freq", { value: value })}
              />
            </LabeledList.Item>
            <LabeledList.Item label="Button">
              <Button
                width="60px"
                color={wire.cut ? 'red' : 'green'}
                content={wire.cut ? 'Off' : 'On'}
                onClick={() => act('cut', {
                  wire: wire.number,
                })} />
            </LabeledList.Item>
          </LabeledList>
        </Section>
      </Window.Content>
    </Window>
  );
};

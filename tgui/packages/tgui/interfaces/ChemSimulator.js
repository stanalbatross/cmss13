import { useBackend } from '../backend';
import { Section } from '../components';
import { Window } from '../layouts';

export const ChemSimulator = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    rsc_credits,
    target,
    reference,
    mode,
    complexity_editor,
    property_costs,
    simulating,
    status_bar,
    ready,
    od_lvl,
    recipe_target,
    recipe_targets,
    property_codings,
  } = data;

  return (
    <Window width={300} height={height}>
      <Window.Content>
        <Section>gawa</Section>
      </Window.Content>
    </Window>
  );
};

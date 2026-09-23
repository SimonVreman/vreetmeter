# Workout program template

Programs can be imported into the Workouts tab (Workouts → Programs → + → Import template) from a JSON file in the format below, and every program can be exported again through the share button on its page. See [example-program.json](example-program.json) for a complete example.

## Program

| Field           | Type              | Required | Description                                                                   |
|-----------------|-------------------|----------|-------------------------------------------------------------------------------|
| `schemaVersion` | number            | yes      | Always `1` for now.                                                           |
| `name`          | string            | yes      | Name of the program.                                                          |
| `notes`         | string            | no       | General notes.                                                                |
| `exercises`     | [ExerciseInfo]    | no       | Extra details for exercises used in the program.                              |
| `weeks`         | [Week]            | yes      | The weeks of the program, in order.                                           |

Exercises are matched by name, ignoring case, so the same exercise in different programs shares its history.

## ExerciseInfo

| Field          | Type   | Required | Description                    |
|----------------|--------|----------|--------------------------------|
| `name`         | string | yes      | Name of the exercise.          |
| `instructions` | string | no       | How to perform the exercise.   |
| `videoURL`     | string | no       | Link to a demonstration video. |

## Week

| Field    | Type   | Required | Description                                                                                      |
|----------|--------|----------|--------------------------------------------------------------------------------------------------|
| `name`   | string | yes      | Name of the week. `{n}` is replaced by the week number in the program, e.g. `"Week {n}"`.        |
| `block`  | string | no       | Block or phase the week belongs to, e.g. `"Block 1: Build"`.                                     |
| `note`   | string | no       | Shown while training this week, e.g. a deload instruction.                                       |
| `repeat` | number | no       | Expands this week into that many identical consecutive weeks. Defaults to `1`.                   |
| `days`   | [Day]  | yes      | The days of the week, in order.                                                                  |

## Day

| Field       | Type       | Required | Description                                                                     |
|-------------|------------|----------|---------------------------------------------------------------------------------|
| `name`      | string     | yes      | Name of the day, e.g. `"Upper #1"`.                                             |
| `kind`      | string     | no       | `"training"` (default), `"optionalRest"` or `"rest"`. Rest days are skipped.    |
| `exercises` | [Exercise] | no       | The exercises of a training day, in order.                                      |

## Exercise

| Field           | Type     | Required | Description                                                                    |
|-----------------|----------|----------|--------------------------------------------------------------------------------|
| `exercise`      | string   | yes      | Name of the exercise.                                                          |
| `substitutions` | [string] | no       | Names of exercises that can be performed instead.                              |
| `superset`      | string   | no       | Exercises with the same label in a day are performed as a superset, e.g. `"A"`.|
| `warmupSets`    | string   | no       | Number of warm-up sets, e.g. `"1-2"`.                                          |
| `sets`          | number   | yes      | Number of working sets.                                                        |
| `reps`          | string   | yes      | Target reps, e.g. `"8-10"`, `"4, 6, 8"` or `"5,4,3+"`.                         |
| `earlyRPE`      | string   | no       | Target RPE of the sets before the last, e.g. `"~8-9"`.                         |
| `lastRPE`       | string   | no       | Target RPE of the last set, e.g. `"10"`.                                       |
| `rest`          | Rest     | no       | Rest between sets.                                                             |
| `technique`     | string   | no       | Intensity technique, e.g. `"Myo-reps"`.                                        |
| `notes`         | string   | no       | Cues and instructions.                                                         |

## Rest

| Field | Type   | Required | Description                           |
|-------|--------|----------|---------------------------------------|
| `min` | number | yes      | Minimum rest in seconds.              |
| `max` | number | no       | Maximum rest in seconds.              |

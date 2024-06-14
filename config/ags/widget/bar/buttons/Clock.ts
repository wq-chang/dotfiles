const datetime = Variable('', {
    poll: [1000, 'date "+%a %b %d %I:%M%p"'],
});

const Clock = Widget.Label({
    label: datetime.bind(),
});

export default Clock;

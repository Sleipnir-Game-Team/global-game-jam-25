using Godot;
using System;
using GodotInk;

public partial class test : VBoxContainer
{
	[Export]
	private InkStory story;
	
	public override void _Ready()
	{
		ContinueStory();
	}

	// Called every frame. 'delta' is the elapsed time since the previous frame.
	public override void _Process(double delta)
	{
	}
	
	private void ContinueStory()
	{
		foreach (Node child in GetChildren())
			child.QueueFree();
			
		Label content = new() { Text = story.ContinueMaximally() };
		AddChild(content);

		foreach (InkChoice choice in story.CurrentChoices)
		{
			Button button = new() { Text = choice.Text };
			button.Pressed += delegate
			{
				story.ChooseChoiceIndex(choice.Index);
				ContinueStory();
			};
			AddChild(button);
		}
	}
}

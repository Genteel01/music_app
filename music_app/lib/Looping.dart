enum LoopType {
  none,
  loop,
  singleSong,
}

String loopingToString(LoopType value)
{
  switch(value)
  {
    case LoopType.none:
      return "none";
    case LoopType.loop:
      return "singleSong";
    case LoopType.singleSong:
      return "loop";
  }
}

LoopType stringToLooping(String value)
{
  switch(value)
  {
    case "none":
      return LoopType.none;
    case "singleSong":
      return LoopType.singleSong;
    case "loop":
      return LoopType.loop;
    default:
      return LoopType.none;
  }
}
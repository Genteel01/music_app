enum SortType {
  ShortestFirst,
  LongestFirst,
  AZ,
  ZA,
}

String sortingToString(SortType value)
{
  switch(value)
  {
    case SortType.ShortestFirst:
      return "Shortest First";
    case SortType.LongestFirst:
      return "Longest First";
    case SortType.AZ:
      return "Name A-Z";
    case SortType.ZA:
      return "Name Z-A";
  }
}

SortType stringToSorting(String value)
{
  switch(value)
  {
    case "Shortest First":
      return SortType.ShortestFirst;
    case "Longest First":
      return SortType.LongestFirst;
    case "Name A-Z":
      return SortType.AZ;
    case "Name Z-A":
      return SortType.ZA;
    default:
      return SortType.AZ;
  }
}